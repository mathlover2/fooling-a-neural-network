## Prerequisites

* Install Anaconda
* Install Tensorflow, Keras, and SciKitLearn through the Anaconda
  package interface
* Install Z Shell

If you want to generate the individual flows from the original dataset
and generate the feature vector files from said flows, the following
additional prerequisites are required.

1. Install pkt2flow. The source for this can be found at
  <https://github.com/caesar0301/pkt2flow>.
  
  After downloading, additional modification of the source may be
  required for the pkt2flow utility to compile. For Debian based
  systems, the following modification works (per use on the Kali Linux
  VM I used for the capstone):
  
  A. In the file `flow_db.c`, remove the following line from the
  source code: 
  
  ```c
  struct ip_pair *pairs [HASH_TBL_SIZE];
  ```
  
  B. In `pkt2flow.c` and `utilities.c`, add the following line:
  
  ```c
  #define _GNU_SOURCE
  ```
  before the include statements.
  
2. Install Scapy.

## Generating flow files and feature vector files from original capture files (optional)

Pregenerated feature vector files for the samples are included in the
`Data` directory. To regenerate them from the original packet capture
files (available through
<http://netweb.ing.unibs.it/~ntw/tools/traces/> via e-mail request, or
from myself on request), extract the contents of the obtained archive
into the `Data` directory, and run the following command:

```zsh
for i in unibs20090930.pcap unibs200910*.pcap
do pkt2flow -uxv -o ${i:r:r} $i
done
```
Afterwards, run

```zsh
./label-from-ground-truth.zsh
./find_labeled_flows.zsh labeledtruth.log
./generate_samples.zsh
```

## Training the model

To train the model, start Jupyter Lab and run all cells in
`TrainModel.ipynb`. Note that several models in addition to the target
model and its prerequisite models are present. By default, the code
for these are commented out. Note that intermediate checkpoints are
saved during model training and early stopping is also used. When
training is finished, note the name of the final model version for
`stacked_cnn_lstm_sae`. 

## Testing the model

To test the model and obtain the confusion matric, run all cells in
`TestModel.ipynb`.

## Testing the adversarial techniques.

For testing FGSM and both versions of JSMA, run all cells in
`FGSM.ipynb` and `JSMA.ipynb`, and `JSMA-v2.ipynb`, but not before
substituting in the file name for `stacked_cnn_lstm_sae` obtained
earler for the one given there.

For testing Mockingbird, run the first 4 cells of `Mockingbird.ipynb`,
and note the final model file name for
`mockingbird_detector_sae`. Modify the file names for
`stacked_cnn_lstm_sae` and `mockingbird_detector_sae` in the fifth
cell accordingly, and then run the remaining cells.
