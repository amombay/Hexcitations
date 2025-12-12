import cv2
import numpy as np
import math
import matplotlib.pyplot as plt

# -----------------------------
# Settings
# -----------------------------
VIDEO_PATH = "Dec11Big/1.MOV"
OUTPUT_PATH = "aruco_tracking_output.mp4"

ARUCO_DICT = cv2.aruco.getPredefinedDictionary(cv2.aruco.DICT_4X4_50)
PARAMS = cv2.aruco.DetectorParameters()

# Dictionaries to store trajectories and angle history
trajectories = {}
angles = {}                  # stored in radians (continuous, relative to first frame)
prev_raw_angles = {}         # store last raw angle for unwrap
initial_angle_offset = {}    # NEW: store first-frame angle so that θ=0 at frame 1

# Time series data
time_steps = []
mean_curvatures = []
mean_polarizations = []

# -----------------------------
# Open video
# -----------------------------
cap = cv2.VideoCapture(VIDEO_PATH)
if not cap.isOpened():
    print("Error: Could not open video.")
    exit()

frame_width  = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
frame_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
fps          = cap.get(cv2.CAP_PROP_FPS)

fourcc = cv2.VideoWriter_fourcc(*'mp4v')
out = cv2.VideoWriter(OUTPUT_PATH, fourcc, fps, (frame_width, frame_height))

# -----------------------------
# Setup Matplotlib live plots
# -----------------------------
plt.ion()
fig, axes = plt.subplots(2, 3, figsize=(16, 9))
fig.canvas.manager.set_window_title("Real-time Analysis")

ax1, ax2, ax3 = axes[0]
ax4, ax5, ax6 = axes[1]

# Titles and labels
ax1.set_title("ArUco Marker Trajectories")
ax1.set_xlabel("X (px)")
ax1.set_ylabel("Y (px)")
ax1.invert_yaxis()
ax1.grid(True)

ax2.set_title("Mean Polarization Ω(t)")
ax2.set_xlabel("Time (s)")
ax2.set_ylabel("Polarization (deg)")
ax2.grid(True)

ax3.set_title("Mean Curvature Θ(t)")
ax3.set_xlabel("Time (s)")
ax3.set_ylabel("Curvature (deg)")
ax3.grid(True)

ax4.set_title("Phase Space Ω vs Θ")
ax4.set_xlabel("Θ (deg)")
ax4.set_ylabel("Ω (deg)")
ax4.grid(True)

ax5.set_title("Individual Marker Angles vs Time")
ax5.set_xlabel("Time (s)")
ax5.set_ylabel("θᵢ(t) (deg)")
ax5.grid(True)

ax6.set_title("Current Chain Configuration")
ax6.set_xlabel("Marker ID")
ax6.set_ylabel("θᵢ (deg)")
ax6.grid(True)

# Plot handles
line_polarization, = ax2.plot([], [], "b-")
line_curvature,   = ax3.plot([], [], "r-")
line_phase,       = ax4.plot([], [], "g-", alpha=0.7)
start_point,      = ax4.plot([], [], "bo", markersize=10)
current_point,    = ax4.plot([], [], "ro", markersize=8)

# -----------------------------
# FRAME LOOP
# -----------------------------
frame_count = 0
print("Processing video... Press 'q' to quit.")

while True:

    ret, frame = cap.read()
    if not ret:
        break

    corners, ids, _ = cv2.aruco.detectMarkers(frame, ARUCO_DICT, parameters=PARAMS)

    current_angles = {}

    if ids is not None:
        ids = ids.flatten()

        for marker_corners, marker_id in zip(corners, ids):

            pts = marker_corners[0]
            cx, cy = int(np.mean(pts[:, 0])), int(np.mean(pts[:, 1]))

            if marker_id not in trajectories:
                trajectories[marker_id] = []
                angles[marker_id] = []
                prev_raw_angles[marker_id] = None
                initial_angle_offset[marker_id] = None   # NEW

            trajectories[marker_id].append((cx, cy))

            # Compute angle
            p1, p2 = pts[0], pts[1]
            raw_angle = math.atan2(p2[1] - p1[1], p2[0] - p1[0])

            # Convert relative to vertical
            raw_angle = raw_angle - math.pi/2

            # Unwrap angle so it never jumps by ±360°
            if prev_raw_angles[marker_id] is None:
                continuous_angle = raw_angle
            else:
                continuous_angle = prev_raw_angles[marker_id] + np.unwrap(
                    [prev_raw_angles[marker_id], raw_angle]
                )[1] - prev_raw_angles[marker_id]

            prev_raw_angles[marker_id] = continuous_angle

            # -----------------------------
            # NEW: FORCE FIRST FRAME TO BE THETA = 0
            # -----------------------------
            if initial_angle_offset[marker_id] is None:
                initial_angle_offset[marker_id] = continuous_angle

            # Subtract baseline
            relative_angle = continuous_angle - initial_angle_offset[marker_id]

            angles[marker_id].append(relative_angle)
            current_angles[marker_id] = relative_angle

            # Draw markers + arrow
            cv2.polylines(frame, [pts.astype(int)], True, (0, 255, 0), 2)
            cv2.circle(frame, (cx, cy), 4, (0, 0, 255), -1)

            arrow_len = 50
            end_x = int(cx + arrow_len * math.cos(raw_angle + math.pi/2))
            end_y = int(cy + arrow_len * math.sin(raw_angle + math.pi/2))
            cv2.arrowedLine(frame, (cx, cy), (end_x, end_y), (255, 0, 0), 2)

            # DEGREE LABEL
            deg_angle = np.degrees(relative_angle)
            cv2.putText(frame, f"ID {marker_id}  {deg_angle:.1f}°",
                        (cx + 10, cy - 10),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.7,
                        (0, 255, 255), 2)

    # Compute mean curvature and polarization
    if len(current_angles) > 1:
        sorted_ids = sorted(current_angles.keys())
        A = np.array([current_angles[i] for i in sorted_ids])

        mean_curvatures.append(A[-1] - A[0])
        mean_polarizations.append(np.mean(A))
        time_steps.append(frame_count / fps)

    # -----------------------------
    # UPDATE PLOTS every 5 frames
    # -----------------------------
    if frame_count % 5 == 0:

        # 1) Trajectories
        ax1.clear()
        ax1.set_title("ArUco Marker Trajectories")
        ax1.set_xlabel("X (px)")
        ax1.set_ylabel("Y (px)")
        ax1.invert_yaxis()
        ax1.grid(True)

        for mid, pts in trajectories.items():
            pts = np.array(pts)
            ax1.plot(pts[:, 0], pts[:, 1], label=f"ID {mid}")
        ax1.legend()

        # Convert to degrees for plots
        deg_curv = np.degrees(mean_curvatures)
        deg_pol  = np.degrees(mean_polarizations)

        if len(time_steps) > 0:
            line_polarization.set_data(time_steps, deg_pol)
            ax2.relim(); ax2.autoscale_view()

            line_curvature.set_data(time_steps, deg_curv)
            ax3.relim(); ax3.autoscale_view()

            line_phase.set_data(deg_curv, deg_pol)
            start_point.set_data([deg_curv[0]], [deg_pol[0]])
            current_point.set_data([deg_curv[-1]], [deg_pol[-1]])
            ax4.relim(); ax4.autoscale_view()

        # 2) Individual angle time-series
        ax5.clear()
        ax5.set_title("Individual Marker Angles vs Time")
        ax5.set_xlabel("Time (s)")
        ax5.set_ylabel("θᵢ (deg)")
        ax5.grid(True)

        for mid in sorted(angles.keys()):
            a = np.degrees(angles[mid])
            t = np.linspace(0, len(a)/fps, len(a))
            ax5.plot(t, a, label=f"ID {mid}")

        ax5.legend()

        # 3) Chain configuration
        ax6.clear()
        ax6.set_title("Current Chain Configuration")
        ax6.set_xlabel("Marker ID")
        ax6.set_ylabel("θᵢ (deg)")
        ax6.grid(True)

        if len(current_angles) > 0:
            sids = sorted(current_angles)
            avals = np.degrees([current_angles[i] for i in sids])
            ax6.plot(sids, avals, "o-", markersize=8)


        plt.tight_layout()

        plt.pause(0.001)

    # -----------------------------
    # Write video + show
    # -----------------------------
    out.write(frame)
    cv2.imshow("Tracking (drag this window beside plots)", frame)

    cv2.waitKey(1)


    frame_count += 1

# -----------------------------
# Cleanup
# -----------------------------
cap.release()
out.release()
cv2.destroyAllWindows()
plt.ioff()
plt.show()

print("Processing complete.")
