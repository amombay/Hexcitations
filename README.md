# Hexcitations
ENGN1735: Vibrations of Mechanical Systems Design Project, Active Particles

Hexcitations is a design project for Brown University's School of Engineering course, ENGN1735: Vibrations of Mechanical Systems, completed by Andrew Mombay, Kaya Bruno, Helen Primis, and Sarah Nguyen in collaboration with the Harris Lab inclusive of Jack-William Barotta and Daniel Harris.

This repository contains the following folders:
- General: This folder contains any general project elements and documentation including our group contract, project proposal, and more.
- CAD Designs: This serves as the general purpose folder containing all CAD designs completed throughout the project, represented across the different iterations and phases of the project.
  - Cage Design: This sub-folder contains all designs of our cages, beginning with our circular cage model before moving to the rectangular, back-held cage model.
    - Iteration I: This sub-folder contains all designs of our intial, circular filament with PVC tubing linkages. These designs were later scrapped and replaced in favor of smaller, more compact linkages as significant issues were faced with friction and mass-dragging due to the sheer weight of the cage and the inability of the hexbug to provide adequate locomotion and movement of the cage for image tracking purposes.
    - Iteration II: This sub-folder contains all designs of our next model where we shifted towards building cages contained on the hexbugs back with a T-shaped marker for tracking purposes along with circular extrusions for the silicone linkages to attach to. This design was later modified and is thus currently redundnant to allow for a better fit on top of the hexbug and silicone linkage.
    - Iteration III: This represents the pre-cursor to our final linkage iteration. Modifications were made to the cage to encourage a better fit of both the cage and silicone linkage.
    - Iteration IV (Final): This represents our most current linkage with spacing for the QR codes for tracking and ensures best-fit for the hexbugs.
  - Linkage Design: This sub-folder contains all linkage mold designs including the 3.5, 4.5, and 5.5mm linkage molds.
    - Iteration I: This sub-folder contains all initial linkage mold designs
    - Iteration II (Final): This sub-folder contains all final linkage mold designs, including the 'key' mold design applied in our final experiemental model.
    - Iteration III (In progress): This sub-folder contains experimental mold designs that should not be used until further work is completed to prevent silicone leakage out of the mold. These molds are currently being explored to reduce extra silicone pieces around the mold and to enhance curing conditons.
  - Misc: This sub-filder contains all additional designs related to constraining the hexbugs movement such as a pole mount, jellyfish-modeled head, and final hexbug stations.
 - MATLAB: This serves as the general purpose folder containing all code regarding tracking software, plotting, and more.
 - Python: This serves as the general purpose folder containing all code regarding tracking software, plotting, and more.

Background: Our project aims to study active particles and observe the collective behaviors and aggregated movement emergent upon coupling through a hexbug-based computational and physical model. In-depth research in this field occurred due to the development of high definition photography which allowed for the detailed scaling of the limb movements for invertebrates and vertebrates. The locomotive functions of the animal's appendages were linked to a central pattern generator in each organism, demonstrating that active particle are driven by autonomous collective movements without the direct influence of a central force. We look to create an accurate model for an adjustable linked filament to mimic cilia-like behaviors by utilizing Hexbugs and 3D-printed Hexbug-like particles to serve as a macroscopic version of the often microscopic particles referenced in the relevant literature. 

Key Goals
- Create an accurate model for an adjustable linked filament to mimic cilia-like behaviors by utilizing Hexbugs, exploring the interplay between the filament elasticity and activity
- Observe and analyze the collective synchronization behavior emergent upon coupling Hexbug active particles with variable bendability
- Investigate four-legged gaits, representative of quadriflagellates by attaching multiple Hexbug filaments to a center pin


Along with each phase of the project, we aim to implement the following modeling approach:
- Physical Modeling: To create the filaments, we plan on using linkages cast from a silicone mold to join the Hexbugs. This allows for semi-constrained movement along the x and y axes. A 3D-printed cage placed on top of each Hexbug allows the linkage to be affixed via prongs, as well as a show a QR code tracking marker to be utilized in Python image processing.
- Mathematical Modeling: Varying lengths of all of the silicone linkages cause the filaments as a whole to have different propensities to bend. To calculate the bendability of the filaments (elastoactive parameter), we first calculate the spring constants to verify the Young’s Modulus. We do this using image processing in MATLAB and can then calculate the corresponding torsional stiffness values and elastoactive parameter. 
- Data Collection: For each phase of this experiment, we use Python ArUco tracking to track the relative position and angular displacement of each Hexbug when fixed at a center point. Using these two elements, we can calculate the mean curvature and polarization for varying configurations of the apparatus upon changing the shape and length of the connection beam, the length of the filament, and the number of hexbugs on each filament.


As of now, we have found the following:
- insert

Currently, our model is complete and ready to explore further scientific modeling and synchronization phenomenon. That being said, additional functionality is entirely possible and is highly recommended to reduce error and enhance both the scope and applications of our model. This includes:
- Building individual hexbugs to reduce any ‘drift’ error where the hexbugs have a general tendency to lean towards the right. Such drift is randomized, with some bugs seeing more significant drift than others due to manufacturing differences. As such, building our own hexbugs would eliminate this drift.
- To control for power differences, we could link our individually built hexbugs to a central power supply and eliminate any differences in supplied power to each component.
- To reduce issues in the silicone linkages, further work could be done on the encapsulated molds to prevent leakage and ensure the mold is completely full to reduce the error of excess silicone attached to the link. In addition, controlling the curing conditions with time, humidity, and temperature would enhance the accuracy of our results by unifying the material properties across all links.


Additionally, we pose the following questions as we continue our work:
- Coding/ Simulation Perspective
    - How can we more robustly track the orientation and positioning of our hexbugs beyond QR code tracking? Is there a way to further minimize any sort of “skipping” when some bugs are enduring lots of rotation in a short amount of time?
    - How can we reduce and/or better account for noise in our modeling?
    - Is there a way for us to test the active force of our particular Hexbugs (commercially or in-house) and would this help our simulation mirror what we are seeing in real-life? 
- Hardware and Design Perspective
  - How can we create a DV-powered homemade model to better simulate collective behavior and brownian motion as opposed to our current model?
  - How can we best implement our design to reduce Hexbug drift and skew towards one direction?
  - How can we best optimize and control cure conditions for the silicone linkages and how might other elastomer linkages impact our model? How do linkage length, stiffness, and cage geometry impact the range and modes of motion in our filament system?
  - How can we elicit multi-filament synchronization in Hexbug behavior? Is this theoretically plausible/ possible? To what extent can we see phase-locking and symmetrical movement compared to biological cilia?






