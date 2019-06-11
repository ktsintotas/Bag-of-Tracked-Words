# Probabilistic Appearance-Based Place Recognition</br> Through Bag of Tracked Words

This open source MATLAB algorith presents a straightforward probabilistic appearance-based Loop Closure Detection (LCD) framework which relies on an image-to-map voting scheme based on an incremental version of Bag-of-Words methods avoiding any pre-trained technique. Feature tracking is performed using Kanade-Lucas-Tomasi (KLT) point tracker and a guided-feature-detection technique. For each tracked feature, a Tracked Word (TW) is generated by averaging the instances of the corresponding descriptors. TWs are assigned to the map representing specific locations along the trajectory, while a Bag-of-Tracked-Words (BoTW) is constructed during the navigation. Working with scale and rotation invariant SURF local-features provides a built-in robustness towards view-point and velocity variations. At query time, local-feature-descriptors vote using a *k*-Nearest Neighbor technique, while a binomial Probability Density Function (PDF) is adapted as a belief generator among the candidate loop closing pairs.

Note that the Bag-of-Track-Words approach is a research code. The authors are not responsible for any errors it may contain. **Use it at your own risk!**

## Conditions of use
Bag-of-Track-Words is distributed under the terms of the [MIT License](https://github.com/ktsintotas/Bag-of-Tracked-Words/blob/master/LICENSE).

## Related publication
The details of the algorithm are explained in the [following publication](https://ieeexplore.ieee.org/document/8633405):

**Probabilistic Appearance-Based Place Recognition Through Bag of Tracked Words<br/>**
Konstantinos A. Tsintotas, Loukas Bampis, and Antonios Gasteratos<br/>
IEEE Robotics and Automation Letters, Vol. 4, No. 2, Pgs. 1737 - 1744 (April 2019)

If you use this code, please cite:

```
@ARTICLE{tsintotas2019probabilistic,
  title={Probabilistic Appearance-Based Place Recognition Through Bag of Tracked Words},  
  author={K. A. Tsintotas and L. Bampis and A. Gasteratos},   
  journal={IEEE Robotics and Automation Letters},     
  year={2019},   
  volume={4},  
  number={2},  
  pages={1737-1744},  
  doi={10.1109/LRA.2019.2897151},  
  month={April}
}
```
## Contact
If you have problems or questions using this code, please contact the author (ktsintot@pme.duth.gr). Ground truth requests and contributions are totally welcome.
