#!/bin/bash

# delete the old mlp and copy the new one
rm notebook/mlp/fold0_best_mlp.pt
cp birdclef-2026/working/checkpoints/fold0_best_mlp.pt notebook/mlp/fold0_best_mlp.pt
echo "moved fold0_best_mlp.pt"

# upload the mlp to Kaggle and get the version value
VERSION_MLP=$(kaggle models instances versions create mateomangialomini/mlp/pytorch/default -p mlp/ | grep -oP 'models/\K[\w/]+$')
echo "new version of mlp is $VERSION_MLP"

# edit the kernel-metadata..json file for the new mlp version
sed -i "s|mateomangialomini/mlp/pytorch/default/[0-9]*|$VERSION_MLP|I" notebook/kernel-metadata.json
echo "modified kernel-metadata.json with mlp version"

# delete the old proto and copy the new one
rm notebook/proto/fold0_best_proto.pt
cp birdclef-2026/working/checkpoints/fold0_best_proto.pt notebook/proto/fold0_best_proto.pt
echo "moved fold0_best_proto.pt"

# upload the proto to Kaggle and get the version value
VERSION_PROTO=$(kaggle models instances versions create mateomangialomini/proto/pytorch/default -p proto/ | grep -oP 'models/\K[\w/]+$')
echo "new version of mlp is $VERSION_PROTO"

# edit the kernel-metadata.json file for the new proto version
sed -i "s|mateomangialomini/proto/pytorch/default/[0-9]*|$VERSION_PROTO|I" notebook/kernel-metadata.json
echo "modified kernel-metadata.json with proto version"

# delete old ensemble weights and copy the new ones
rm notebook/ensemble_weights/ensemble_weights.npy
cp birdclef-2026/working/outputs/ensemble_weights.npy notebook/ensemble_weights/ensemble_weights.npy
echo "moved ensemble_weights.npy"

# upload the dataset to Kaggle
kaggle datasets version -p notebook/ensemble_weights -m ""
echo "uploaded ensemble_weights.npy"

# delete old notebook and copy the new one
rm notebook/notebook.ipynb
cp notebook.ipynb notebook/notebook.ipynb
echo "moved new notebook"

sed -i 's/TRAIN_MODE      = True/TRAIN_MODE      = False/' notebook/notebook.ipynb
sed -i 's/INFERENCE_MODE  = False/INFERENCE_MODE  = True/' notebook/notebook.ipynb
echo "set notebook to inference mode"

# upload and run the notebook on Kaggle
kaggle kernels push -p notebook
echo "uploaded new notebook"
