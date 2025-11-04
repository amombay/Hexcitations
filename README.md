# Hexcitations
ENGN1735: Vibrations of Mechanical Systems Design Project, Active Particles

Hexcitations is a design project for Brown University's School of Engineering course, ENGN1735: Vibrations of Mechanical Systems, completed by Andrew Mombay, Kaya Bruno, Helen Primis, and Sarah Nguyen in collaboration with the Harris Lab inclusive of Jack-William Barotta and Daniel Harris.

This repository contains the following folders:
-General: This folder contains any general project elements and documentation including our group contract, project proposal, and more.
- CAD Designs: This serves as the general purpose folder containing all CAD designs completed throughout the project, represented across the different iterations and phases of the project.
  -Cage Design: This sub-folder contains all designs of our cages, beginning with our circular cage model before moving to the rectangular, back-held cage model.
    - Iteration I: This sub-folder contains all designs of our intial, circular filament with PVC tubing linkages. These designs were later scrapped and replaced in favor of smaller, more compact linkages as significant issues were faced with friction and mass-dragging due to the sheer weight of the cage and the inability of the hexbug to provide adequate locomotion and movement of the cage for image tracking purposes.
    - Iteration II: This sub-folder contains all designs of our next model where we shifted towards building cages contained on the hexbugs back with a T-shaped marker for tracking purposes along with circular extrusions for the silicone linkages to attach to. This design was later modified and is thus currently redundnant to allow for a better fit on top of the hexbug and silicone linkage.
    - Iteration III: This represents our most current linkage iteration. Modifications were made to the cage to encourage a better fit of both the cage and silicone linkage.
   -Linkage Design: This sub-folder contains all linkage mold designs including the 3.5, 4.5, and 5.5mm linkage molds.
 - MATLAB: This serves as the general purpose folder containing all code regarding tracking software, plotting, and more.
 - Revelant Literature: This folder lists current, appropriate sources used to support our work.

Background: Our project aims to study active particles and observe the collective behaviors and aggregated movement emergent upon coupling. In-depth research in this field occurred due to the development of high definition photography which allowed for the detailed scaling of the limb movements for invertebrates and vertebrates. The locomotive functions of the animal's appendages were linked to a central pattern generator in each organism, demonstrating that active particle are driven by autonomous collective movements without the direct influence of a central force. We look to create an accurate model for an adjustable linked filament to mimic cilia-like behaviors by utilizing Hexbugs and 3D-printed Hexbug-like particles to serve as a macroscopic version of the often microscopic particles referenced in the relevant literature. We will create both a battery based and direct voltage sourced filament before applying our filament to model the appendage based movement of a jellyfish. This will allow us to explore how different orientations and combinations of filament power and length affect the velocity of our model’s movement.

The key questions we hope to address are as follows:
- How can we build a cilia-like filament by employing 3D-printable hexbugs and mechatronic principles?
- How do different orientations of hexbug coupling influence their collective actuation?
- How does torsional stiffness influence synchronization and sustained oscillations in elastic networks?
- Can we achieve biomimicry with our model?

For this project, we aim to implement the following project phases to model our project:
- PHASE I: We utilize Hexbug Nanos from the Harris lab as the macroscopic active particles within the filament. We provide a linkage point made from a silicone mold between each discrete bug. The filament will be attached to one fixed non-powered source, such as a cilia attached to the parent body.
- PHASE II: We 3D print and construct Hexbugs that can be connected via wiring to a fixed direct voltage source, eliminating the need of the battery powered Hexbug Nanos. This design will be modular to allow for adjustable filament length and attachments.
- PHASE III: We engage with the concept of biomimicry using the DV-source based filament design. We attach multiple appendages to one unfixed central body, mimicking a jellyfish, investigating the Hexbug orientations that generate the most thrust considering different lengths and numbers of cilia attached to the beam.

Along with each phase of the project, we aim to implement the following modeling approach:
- Physical Modeling: To create the filaments, we plan on use linkages cast from a silicone mold to join the Hexbugs. This allows for semi-constrained movement along the x and y axes. A 3D-printed cage placed on top of each Hexbug allows the linkage to be affixed via prongs, as well as a show a T-shaped tracking marker to be utilized in MATLAB image processing.
- Data Collection: For each phase of this experiment, we use MATLAB particle tracking to track the relative displacements and velocities of each particle (x, y, theta) to the fixed base. This allows us to consistently measure the tracked values of the Hexbug’s movement. We can break down their behavior based on their position, velocity, angle of movement, and general error due to inconsistencies in the hexbugs and the surface. In particular for phase III, we collect mean curvature and polarization data for varying configurations of the apparatus upon changing shape and length of connection beam, length of filament, number of hexbugs on each filament. 

As of now, we have found the following:
- Influence of Preliminary Findings: Throughout our phase I modeling process, we’ve evolved the physical setup of the experiment, through iteration of the cages and linkages. This has allowed us to understand which experimental setup is best for collecting position and velocity data, and easiest to recreate. Having the connection point of the Hexbugs above the surface on which they move helps to reduce friction and show increased movement. Therefore, we look to continue linking the filament via the 3D printed cages that sit atop the Hexbugs.
- Questions and Uncertainties: A question we have moving forward is determining the best way to tag the Hexbugs, ensuring the most accurate representation for processing in MATLAB.
- Roadblocks and Challenges: Current challenges are finalizing the linkages between the Hexbugs and continuing to investigate silicone as the connecting material.

Our next steps are as follows:
- Next Steps: We look to move forward into phase II of our modeling process, by printing and constructing Hexbugs that can be connected via wiring to a fixed direct voltage source. This includes experimenting with pager motors and circuitry.
- Timeline:
  - 11/7: Assemble phase II model with 3D printed Hexbugs connected to direct voltage source via wiring. Conduct experimental trials of different numbers of Hexbugs in filament
  - 11/14: Continue phase II experimental trials, and analyze experimental data
  - 11/21: Begin phase III model with multiple filaments attached to one unfixed central body, mimicking a jellyfish.
  - 11/28: Conduct phase III experimental trials, investigating the Hexbug orientations that move the fastest considering different lengths and numbers of cilia attached to the beam. Work on technical report
  - 12/5: Complete open source Github, including CAD designs, code, raw and processed data as well as technical report
  - 12/12: Finalize final presentation slides, practice presentations
  - 12/13: Final presentation of deliverable, and final group evaluations

