# Thesis Reiteration Report

**Yifei Liu, 9/5**

[TOC]

## Ques. 1: Description of MRP

The maximum reflectance prior (**MRP**) is a general rule based on statistics of daytime haze-free image patches, which shows, that in the most patches of a daytime haze-free image, each color channel has very high intensity at some pixels (the pixels don’t have to be the same one). For the purpose of describing this prior in mathematical language, we define the maximum of pixel intensity  (**MPI**) in a channel $\lambda$ of the specific patch $\Omega_i$ .
$$
M_{\Omega}^{\lambda}=\max_{j\in\Omega_i}I_j^{\lambda}
$$


Where $I$ denotes a daytime haze-free image. So, the MRP could be described as follows, and we should mention that in this term $M$ has been normalized:
$$
M_{\Omega}^{\lambda} \approx 1
$$

In daytime, we can assume that  incident light intensities are uniform in space and can be assumed to be fixed to value 1. Therefore, $L_J=const$ , we can further deduct that:
$$
M_{\Omega}^{\lambda}=\max_{j\in\Omega_i}R_j^{\lambda}\\
\max_{j\in\Omega_i}R_j^{\lambda} \approx 1
$$
That’s why it calls maximum reflectance prior.

## Ques. 2: General Principle & Pseudocode

### the Buildup of Nighttime Model

For the purpose of dehaze a night image, a practical model for night haze process needed to be build. The model applied for daytime haze scenes is described as follows:
$$
I_i^{\lambda}=J_i^{\lambda}t_i+A^{\lambda}(1-t_i)
$$
What should be mentioned is that $A^{\lambda}$ denotes the global atmospheric light, which is failed to make sense in night. According to the discussion in the Sec. 1, nighttime scene are : 1.  multiple colored 2. have strongly non-uniform ambient illumination. As a result, the term $A_i^{\lambda}$ is separated into two terms as follows:
$$
A^{\lambda}_i \triangleq L_i\eta^{\lambda}_i
$$
where $L_i$ is the  ambient illumination shows the distribution in space, and $\eta^{\lambda}_i$ shows the color distribution in space. The final model is described as follows:
$$
I_i^{\lambda} \triangleq L_i\eta_i^{\lambda}R_i^{\lambda}t_i+L_i\eta_i^{\lambda}(1-t_i)
$$

### the Estimation of Ambient Illumination

Now, the aim of the dehaze process is to recover color-balanced haze free image, which is denoted as $J_i^{\lambda} \triangleq L_jR_j^{\lambda}$ . The first step is to estimate ambient illumination. In other words, we need to get $L_i,\eta_i^{\lambda}$  from above expression.

According to the  answer of QUES.1 above, we already knows that MRP stands for:
$$
M_{\Omega}^{\lambda}=\max_{j\in\Omega_i}I_j^{\lambda} \approx 1
$$
Now let’s focus on the nighttime circumstance. Based on the assumption that $L_{\Omega_i},\eta_{\Omega_i}^{\lambda},t_{\Omega_i}$ are constant in each patch, the equations in the paper could deviate the estimation of  ambient illumination by (details are omitted) :
$$
M_{\Omega}^{\lambda}=L_{\Omega_i}\eta_{\Omega_i}^{\lambda}\\
\eta_{\Omega_i}^{\lambda}=\frac{M_{\Omega}^{\lambda}}{L_{\Omega_i}}
$$
In the expressions above, we let $L_{\Omega_i}=\max_{\lambda\in\{R,G,B\}}M_{\Omega}^{\lambda}$ . Then, we refine $\eta_{\Omega_i}^{\lambda}$ by applying image guided filter. The guided image $I$ is selected to be the grey image of original haze image. Finally, remove the color effect:
$$
\hat I_i^{\lambda} \triangleq L_iR_i^{\lambda}t_i+L_i(1-t_i)
$$

### the Estimation of Scene Transmission

In this portion, we take the same procedure above by applying the $\max$ operation and get the MPI again. Similarly, we get the $L_{\Omega}$ in each channel and select the maximum one as the final estimate. 
$$
L_{\Omega_i}=\max_{\lambda\in\{R,G,B\}}\left(\max_{j\in\Omega_i}\hat I_j^{\lambda}\right)
$$
 Once again, we refine the estimate to get a smooth $L_i$ by using guided filter. 

Now, the model described as:
$$
\hat I_i^{\lambda} = J_i^{\lambda}t_i+L_i(1-t_i)
$$
Using the dark channel prior introduced in the reference paper of K. He et al, we can get the estimate of $t_{\Omega}$  , and refine it using guided filter.

### Haze removal

Having get the detailed estimate of $L_j,t_j$ , we can deduct the haze-free image from definition of $\hat I_i^{\lambda}$ above:
$$
J^{\lambda}_j=\frac{\hat I_i^{\lambda}-L_j}{\max{(t_j,t_0)}}+L_j
$$

### Algorithm

**input:** input image $I$, patch size $R$, filter kernel size $r$, filter parameter $\epsilon$

**output:** dehaze image $J$

1: calculate $M_{\Omega}^{\lambda}$,   $L_{\Omega_i}=\max_{\lambda\in\{R,G,B\}}M_{\Omega}^{\lambda}$, normalize  $\eta_{\Omega_i}^{\lambda}=\frac{M_{\Omega}^{\lambda}}{L_{\Omega_i}}$  and refine $\eta_j^{\lambda}=f_{\epsilon}\left (\eta_{\Omega_i}^{\lambda} \right)$

2: recover: $\hat I_j^{\lambda}=\frac{I_j^{\lambda}}{\eta_j^{\lambda}}$

3: $L_{\Omega_i}=\max_{\lambda\in\{R,G,B\}}\left(\max_{j\in\Omega_i}\hat I_j^{\lambda}\right)$ , refine $L_{j}=f_{\epsilon}\left (L_{\Omega_i} \right)$

4: $t_{\Omega}=1-\frac{\min_{\lambda\in\{R,G,B\}}\min_{j\in \Omega_i}\hat I_j^{\lambda}}{\min_{j\in \Omega_i}L_j}$ , refine $t_{j}=f_{\epsilon}\left (t_{\Omega} \right)$

5: $J^{\lambda}_j=\frac{\hat I_i^{\lambda}-L_j}{\max{(t_j,t_0)}}+L_j$

/* note that $f_{\epsilon}\left (* \right)$  means apply a guided filter using parameter $\epsilon$ , and the guided image is the grey image of original image */

## Ques. 3: Test Report

We implement the proposed algorithms using matlab (ver. 2018a) on a Laptop with Intel CORE  i5-8250U (1.80GHz) and 8G memories.

The parameters are set as follows:

```matlab
patchsize_x = 15;
patchsize_y = 15;
GuidedFilter_size = 32;
GuidedFilter_para = 0.01;
```

The time consumption based on given image set is as follows: 

|   image    | time consumption () |
| :--------: | :-----------------: |
| Image1.bmp |       单元格        |
| Image2.bmp |       单元格        |
| Image3.bmp |       单元格        |
| Image4.bmp |       单元格        |
| Image5.bmp |       单元格        |





