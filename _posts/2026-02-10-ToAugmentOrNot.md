---
layout: distill
title: To Augment or Not to Augment? Diagnosing Distributional Symmetry Breaking
description: Symmetry-aware methods for machine learning, such as data augmentation and equivariant architectures, encourage correct model behavior on all transformations (e.g. rotations or permutations) of the original dataset. These methods can improve generalization and sample efficiency, under the assumption that the transformed datapoints are highly probable, or ``important'', under the test distribution. In this work, we develop a method for critically evaluating this assumption. In particular, we propose a metric to quantify the amount of anisotropy, or symmetry-breaking, in a dataset, via a two-sample neural classifier test that distinguishes between the original dataset and its randomly augmented equivalent. We validate our metric on synthetic datasets, and then use it to uncover surprisingly high degrees of anisotropy in several benchmark point cloud datasets. We show theoretically that distributional symmetry-breaking can actually prevent invariant methods from performing optimally even when the underlying labels are truly invariant, as we show for invariant ridge regression in the infinite feature limit. Empirically, we find that the implication for symmetry-aware methods is dataset-dependent, equivariant methods still impart benefits on some anisotropic datasets, but not others. Overall, these findings suggest that understanding equivariance — both when it works, and why — may require rethinking symmetry biases in the data.
date: 2026-02-10
future: true
htmlwidgets: true
hidden: true

# Mermaid diagrams
mermaid:
  enabled: true
  zoomable: true

# Anonymize when submitting
authors:
   - name: Anonymous

#authors:
#  - name: Albert Einstein
#    url: "https://en.wikipedia.org/wiki/Albert_Einstein"
#    affiliations:
#      name: IAS, Princeton
#  - name: Boris Podolsky
#    url: "https://en.wikipedia.org/wiki/Boris_Podolsky"
#    affiliations:
#      name: IAS, Princeton
#  - name: Nathan Rosen
#    url: "https://en.wikipedia.org/wiki/Nathan_Rosen"
#    affiliations:
#      name: IAS, Princeton

# must be the exact same name as your blogpost
bibliography: 2026-02-10-ToAugmentOrNot.bib

# Add a table of contents to your post.
#   - make sure that TOC names match the actual section names
#     for hyperlinks within the post to work correctly.
#   - please use this format rather than manually creating a markdown table of contents.
toc:
  - name: Introduction
  - name: Distributional Symmetry Breaking
  - name: Proposed Metric
  - name: Theory
  - name: Experiments
  - name: Hypotheses for Empirical Behavior
  - name: Conclusion
  - name: References

# Below is an example of injecting additional post-specific styles.
# This is used in the 'Layouts' section of this post.
# If you use this post as a template, delete this _styles block.
_styles: >
  .fake-img {
    background: #bbb;
    border: 1px solid rgba(0, 0, 0, 0.1);
    box-shadow: 0 0px 4px rgba(0, 0, 0, 0.1);
    margin-bottom: 12px;
  }
  .fake-img p {
    font-family: monospace;
    color: white;
    text-align: left;
    margin: 12px 0;
    text-align: center;
    font-size: 16px;
  }
---

**TL;DR:** We explore the implications of symmetry breaking in data distributions and present a new metric to quantify the amount of symmetry broken. We explore the implications of distributional symmetry breaking for machine learning practitioners. 

## Introduction

Both data augmentation and equivariant neural networks have become popular tools in modern machine learning to enforce symmetries, with equivariant neural networks achieving superior performance across materials science <d-cite key="liao2023equiformerv2"></d-cite>, robotics <d-cite key="wang2024equivariant"></d-cite>, drug discovery <d-cite key="igashov2024equivariant"></d-cite>, fluid dynamics <d-cite key="wangincorporating"></d-cite>, computer vision <d-cite key="esteves2019equivariant"></d-cite>, and beyond. For $g\in G$ a group symmetry transformation, such as a rotation or permutation, a function $$f$$ is equivariant if $$f(gx) = g(fx)$$, and invariant if $$f(gx) = f(x)$$. Similarly, a model $$\text{NN}$$ is equivariant if it is architecturally constrained such that $$\text{NN}(gx)=g\text{NN}(x)$$, tying the predictions for $$x$$ and $$gx$$. Data augmentation may also be used to enforce symmetries by applying a random group element $$g$$ to each input in the training set and its corresponding label, thus encouraging the model to learn equivariant or invariant behavior. 

Both approaches rely on the assumption that the ground truth function $$f$$ is equivariant. However, there is often an implicit assumption that the data distribution itself is symmetric, i.e. $$p(x) \approx p(gx)$$. We refer to violations of this assumption as **distributional symmetry breaking**. In this work, we study distributional symmetry breaking. Our main contributions are:

- **A classifier-based diagnostic:** We introduce a simple two-sample test to measure distributional symmetry breaking.

- **Theoretical analysis:** We show that data augmentation can harm performance under certain distributional conditions.

- **Empirical studies:** We demonstrate that widely used 3D datasets are strongly canonicalized. We correspondingly evaluate the impacts of equivariant methods on datasets across domains and propose hypotheses for differing behaviors.

## Distributional Symmetry Breaking

{% include figure.liquid path="assets/img/2026-02-10-ToAugmentOrNot/orientations.png" class="img-fluid" %}
<div class="caption">
    A visualization of orientation biases.
</div>
The figure above shows examples of **distributional symmetry breaking**. Baseballs are likely to occur in any orientation in photos, and are therefore uniform across orbits. Coffee mugs are more likely to appear with the handle on the side, illustrating distributional symmetry breaking. The middle shows an example of **canonicalization**, where an object only ever apprears in one canonical orientation. This is the strongest form of distributional symmetry breaking. Canonicalization can also be **inherent**, such as a digit's orientation that determines whether it is a 6 or a 9, or **user-defined**, such as the orientiation of a crystal lattice. Distributional symmetry breaking may lead equivariant methods or data augmentation to discard useful information. For example, classifying 6s and 9s in MNIST is easy when the digits appear in their natural orientation, but it becomes harder under rotational augmentation.

## Proposed Metric

Thus, we propose a metric to answer the question: **how much does the data distribution break symmetry?**.  We define a metric $$m(p_X)$$ which measures how close the data distribution $p_X$ is to being symmetric. Formally, the symmetrized density is

$$
\bar{p}_X(x) := \int_{g\in G}p_X(gx)dg
$$

We can obtain samples from $$\bar{p}_X(x)$$ by applying random $$G$$-augmentations. We would like $$m(p_X)$$ to approximate some notion of distance $$d$$ between $$p_X$$ and $$\bar{p}_X$$. Intuitively, if $$d$$ is small, the dataset is already symmetric. If $$d$$ is large, some orientations or transformations are more likely than others, illustrating distributional symmetry breaking.

<d-cite key="chiu2023nonparametric"></d-cite> sets $$d$$ to be the maximum mean discrepancy (MMD) with respect to some choice of kernel, corresponding to a non-parametric two sample statistical test. However, there is not always a clear choice of kernel. Thus, we propose a two sample classifier test, a common tool for detecting and quantifying distribution shift in machine learning <d-cite key="twosampletest"></d-cite>. 

Our approach is both simple and interpretable as follows:
1. Split the dataset in half
2. Apply random transformations $$g \in G$$ to one half to create the augmented class.
3. Train a small neural network to distinguish between original and transformed samples.
4. Use the **test accuracy** as the metric:

$$
m(p_X) := \text{accuracy of classifier distinguishing } (p_X, \bar{p}_X)
$$

Intuitively, if the dataset is symmetric, the classifier can't tell the difference ($$m(p_X) \approx 0.5$$). If it is canonicalized, the classifier can easily tell ($$m(p_X) \approx 1).

<div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 1rem;">

  <figure style="flex: 1; text-align: center;">
    {% include figure.liquid path="assets/img/2026-02-10-ToAugmentOrNot/dataset_vis.png" class="img-fluid" %}
    <figcaption>Visualizations of unrotated samples from several materials datasets, with their canonicalization visible.</figcaption>
  </figure>

  <figure style="flex: 1; text-align: center;">
    {% include figure.liquid path="assets/img/2026-02-10-ToAugmentOrNot/classifer_setup1.png" class="img-fluid" %}
    <figcaption>A classifier test for determining if a sample is from the original dataset, or rotated.</figcaption>
  </figure>

</div>

## Theory

## Experiments

Our theoretical analysis predicts that equivariant methods can sometimes harm performance when datasets exhibit distributional symmetry breaking. First, we measure $$m(p_X)$$ on multiple benchmark datasets to quantify the extent of distributional symmetry breaking. Strikingly, we find that many widely-used benchmark datasets are strongly canonicalized, particularly molecular/materials science datasets used for benchmarking equivariant models. This reveals that real-world datasets often deviate substantially from the symmetry assumptions build into equivariant models.

We then evaluate equivariant, group-averaged, and stochastic group-averaged models on each dataset to disentangle the relationship between canonicalization and model performance. While one might hypothesize that augmentation on highly canonicalized datasets would consistently degrade performance, molecular datasets (such as QM7b and QM9) defy this simple picture, suggesting that task-specific structure plays a crucial role in determining whether equivariance helps or hurts.

{% include figure.liquid path="assets/img/2026-02-10-ToAugmentOrNot/model_table.png" class="img-fluid" %}
<div class="caption">
    Comparison of train/test augmentation, group-averaged, and equivariant models across datasets. Augmentation: TT = train+test, TF = train only, FT = test only, FF = none. MNIST uses a group-averaged model; other datasets use stochastic group-averaging. MAE is reported for QM7b/QM9; equivariant baselines from e3nn. Best overall in bold, best within augmentation underlined. CNN used for MNIST, graph transformer for point clouds.
</div>

We discuss each dataset in turn:

- **MNIST**: Digits should intuitively be mostly canonicalized with respect to $$90^\circ$$ rotations ($$C_4$$). Rotational alignment is strong, with $$m(p_X)$$ high. Augmentation has minimal effect on performance, with no-augmentation (FF) setting performing slightly better.
- **ModelNet40**: A more complex benchmark dataset for shape recognition consisting of 12,311 CAD models across 40 common object categories. Class-specific $$m(p_X)$$ confirms high alignment. Augmentation generally reduces performance.
- **QM9**: Consists of 133k small stable organic molecules %
with $$\leq$$ 9 heavy atoms, together with scalar quantum mechanical properties. Highly canonicalized due to preprocessing using the commercial software CORINA <d-cite key="qm9"></d-cite> with high $$m(p_X)$$. Equivariance or augmentation improves performance for nearly all properties, highlighting dataset specific behavior.
- **QM7b**: 7,211 molecule subset of GDB-13 (a database of stable and synthetically accessible organic molecules <d-cite key="qm7original1"></d-cite>). We use a version of the dataset<d-cite key="qm7byang2019quantum"></d-cite> containing non-scalar material response properties to explore how distributional symmetry breaking affects higher order geometric quantities. Highly canonicalized. Equivariance and augmentation are particularly beneficial for non-scalar properties (i.e. the dipole moment).

<div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 1rem;">

  <figure style="flex: 1; text-align: center;">
    {% include figure.liquid path="assets/img/2026-02-10-ToAugmentOrNot/ModelNet_metric.png" class="img-fluid" %}
    <figcaption>ModelNet40 classifier metric histogram over classes.</figcaption>
  </figure>

  <figure style="flex: 1; text-align: center;">
    {% include figure.liquid path="assets/img/2026-02-10-ToAugmentOrNot/rMD17_metric.png" class="img-fluid" %}
    <figcaption>Test accuracy vs rotated fraction for aspirin and ethanol from rMD17, OC20 surface+adsorbate, OC20 adsorbate, and QM9.</figcaption>
  </figure>

</div>

### Additional Materials Science Datasets

We quantify distributional symmetry breaking for additional materials science datasets. 
- **rMD17**: Contains 100k structures from molecular dynamics simulations <d-cite key="rMD17"></d-cite>. The degree of distributional symmetry breaking varies widely between molecules in rMD17. This could be both due to the initial conditions for the simulation, and the differing physical structures of each molecule.
- **OC20**: Simulations consisting of adsorbates placed on periodic crystalline catalysts <d-cite key="OC20"></d-cite>. Both the adsorbate and the adsorbate + catalyst are highly canonicalized, likely due to the catalyst's alignment with the $$xy$$ plane.
- **LLM Dataset**: Interest has recently grown in using LLMs for crystal structure generation. <d-cite key="gruver2024finetuned"></d-cite> convert crystals into a text format, which requires listing their atoms in some ordering. The authors independently noted that permutation augmentations hurt generative performance, even though the task is ostensibly permutation invariant. We postulated that this phenomenon was due to distributional symmetry-breaking, i.e. conventions in the generation of atom order. We thus trained a classifier head on a pretrained DistilBERT transformer to distinguish between permuted and unpermuted datapoints, and found $$m(p_X)= 95\%$$ accuracy.


**Key Observations:** $$m(p_X)$$ provides a concrete way to measure the degree of canonicalization present in a datatset. Many widely-used benchmarks — especially in molecular and materials science — deviate significantly from the symmetry assumptions built into equivariant models. However, **task structure matters**, as equivariant models/data augmentation perform well on molecular datasets.

## Hypotheses
We present hypotheses for the differing performance of equivariant models/data augmentation across datasets.

### Task Dependent Metric
The value $$m(p_X)$$ determines whether there is discernible lack of uniformity over group transformations in the unlabeled dataset. However, it does not capture whether that distributional symmetry breaking (e.g. preferred orientations) is correlated with the specific task labels,  such as in the case of MNIST 6s/9s. If it does, then we hypothesize that augmenting is a poor choice, as it discards task-relevant information contained in orientations. Thus, we introduce a metric of **task-useful** distributional symmetry breaking. 

Let $$c\colon\mathcal{X} \rightarrow G$$ be a canonicalization function, denoting where on each orbit $$x$$ is. Since data augmentation destroys any information contained in $$c(x)$$, we wish to understand the dependence between orientations $$c(x)$$ and labels $$f(x)$$. A natural way to do this is to predict $$f(x)$$ directly from $$c(x)$$, where $$c(x)$$ is a randomly initialized, untrained equivariant neural network (a canonicalization function). We then compare the test criterion $$\mathcal{L}(c(x) \to f(x))$$ to that obtained when the inputs are randomly transformed by elements of the given group, $$\mathcal{L}_{\text{rot}} = \mathcal{L}(c(gx) \to f(gx)), g \sim G$$.  
which removes any task-relevant information in the orientations (where $$\mathcal{L}$$ is the performance on the test set, e.g. accuracy/MAE).

We first explore an artificial **QM7b dipole** canonicalization. This is a constructed example of a very task-relevant canonicalization, where molecules are aligned such that their dipole moments are along the $z$ axis. This makes it easy for a non-equivariant model to predict dipoles, while an equivariant model cannot exploit this alignment. This is confirmed empirically where with the dipole canonicalization, the FF augmentation setting outperforms an equivariant model. The task-dependent metric indeed yields a large signal when applied to the dipole-canonicalized dataset. **ModelNet** is another case where equivariance harms performance, and the task-dependent metric shows a large signal. In contrast, for the **QM9** properties shown, the metric shows a small signal.

{% include figure.liquid 
  path="assets/img/2026-02-10-ToAugmentOrNot/task_dependent_results.png"
  class="img-fluid"
  caption="(Top) QM7b dipole canonicalization performance. (Bottom) Task-dependent metric: Accuracy (ModelNet) or MAE (QM7b/QM9) of predicting the label from the canonicalization versus a baseline with random rotations. Values averaged over five seeds."
%}

The relative signal above shows the accuracy of predicting $$f(x)$$ from $$c(x)$$ vs. a baseline with randon rotations. The relative signal shows how $$\mathcal{L}$$ changes under rotation: $$\mathcal{L}_{rot} / \mathcal{L}$$ for error metrics (lower better) and $$\mathcal{L} / \mathcal{L}_{rot}$$ for accuracy (higher better). Thus, our experiments show that the task-dependent metric is generally larger for tasks where equivariance does **not** improve performance.

### Locality

One possible explanation for the mixed empirical results is that equivariant models primarily exploit local equivariance, rather than global symmetry. Equivariant CNNs and GNNs compute features that are equivariant functions of their receptive fields, meaning they are inherently locally equivariant <d-cite key="musaelian2023local"></d-cite>. The practical benefit of equivariance may therefore come from capturing structure in small, recurring motifs — for example, local chemical environments in molecules — rather than enforcing strict global symmetry <d-cite key="du2022se3,lippmann2025beyond"></d-cite>.

This perspective helps clarify the apparent discrepancy between ModelNet40 and QM9. Both datasets are strongly canonicalized at the global level. The key difference may lie in how symmetry behaves locally. To test this hypothesis, we use $$m(p_X)$$ to compare global and local distributional symmetry breaking.

Concretely, we generate the local QM9 dataset by extracting local neighborhoods (by bonds) from each molecule in QM9. We compare $$m(p_X)$$ between local and ordinary QM9 in three settings: the original datasets (exploration), and under random rotation and manual canonicalization (as sanity checks, which should yield $$50\%$$ and $$100\%$$, respectively). We find that the detection accuracy is much lower for local QM9, indicating a lower degree of local distributional symmetry breaking! 

For ModelNet40, we analogously constructed a local dataset by randomly selecting one point from each original, $1024$-point point cloud, and then collecting its $N$ nearest neighbors. When the number of sampled points is small, the metric drops significantly, indicating that local regions of the point clouds are not inherently canonicalized. However, as neighborhoods grow, canonical alignment quickly re-emerges. These results suggest that:
- In QM9, useful predictive structure resides in locally isotropic motifs. Equivariant models benefit from modeling these.
- In ModelNet40, object-level canonicalization is more tightly coupled to the task (object identity), so breaking that alignment through augmentation removes useful signal. 

{% include figure.liquid path="assets/img/2026-02-10-ToAugmentOrNot/locality_exp.png" class="img-fluid" %}
<div class="caption">
    Left: The local QM9 dataset (top) and results (bottom). Right: Local ModelNet40 results.
</div>

Thus, the relevant question is not simply whether a dataset is canonicalized, but at what scale canonicalization interacts with the task. Local equivariance may help when symmetry breaking is primarily global and incidental (as in QM9), but hurt when canonical alignment itself carries task-relevant information (as in ModelNet40).

## Conclusion

We provide both empirical and theoretical analysis of distributional asymmetry and its implications for learning. Our interpretable metrics quantify the degree of symmetry-breaking present in a dataset without using any specific knowledge of the domain, thus providing practioners with a simple diagnostic for detecting distributional symmetry breaking in their datasets. Experiments revealed a high degree of symmetry-breaking in every benchmark dataset, yet
augmentation only impeded (test) performance for ModelNet40 and MNIST.

Overall, these findings have intriguing implications for equivariant learning. First, they affirm that 
if evaluated only on in-distribution validation data, non-equivariant models may appear accurate, yet fail to generalize under transformations. We provide a flowchart on how to use our metrics for practitioners.

{% include figure.liquid 
  path="assets/img/2026-02-10-ToAugmentOrNot/symm_breaking_flowchart.png"
  class="img-fluid"
  caption="Advice for practitioners on using our metric for model selection."
%}

Moreover, canonicalizing to data has been proposed as a flexible method for making black-box models globally equivariant <d-cite key="kaba2023equivariance"></d-cite>. However, if molecular datasets both are already canonicalized and still experience benefits from augmentation and equivariance, this suggests that they provide some **additional**, possibly **domain-specific** benefit beyond global equivariance that is currently unexplained. Finally, data augmentation is often considered universally beneficial for invariant tasks, yet we show that it can sometimes hurt performance on the test set. Predicting when and why different data augmentations can benefit learning, even in the case of nearly canonicalized data, is a useful future direction.

## References
