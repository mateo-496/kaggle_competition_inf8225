#!/bin/bash

echo "================================================"
echo "     BirdCLEF+ 2026 — Kaggle Upload Pipeline    "
echo "================================================"
echo ""

# delete the old mlp and copy the new one
echo "[1/6] Updating MLP checkpoint..."
rm notebook/mlp/fold0_best_mlp.pt
cp birdclef-2026/working/checkpoints/fold0_best_mlp.pt notebook/mlp/fold0_best_mlp.pt

# upload the mlp to Kaggle and get the version value
echo "[2/6] Uploading MLP model to Kaggle..."
MLP_DIR="notebook/mlp"
VERSION_MLP=$(kaggle models instances versions create mateomangialomini/mlp/pytorch/default -p "$MLP_DIR" | tee /dev/tty  | grep -oP 'models/\K[\w/]+$' | tr '[:upper:]' '[:lower:]')
echo "      → $VERSION_MLP"
echo ""

# delete the old proto and copy the new one
echo "[3/6] Updating ProtoSSM checkpoint..."
rm notebook/proto/fold0_best_proto.pt
cp birdclef-2026/working/checkpoints/fold0_best_proto.pt notebook/proto/fold0_best_proto.pt

# upload the proto to Kaggle and get the version value
echo "[4/6] Uploading ProtoSSM model to Kaggle..."
PROTO_DIR="notebook/proto"
VERSION_PROTO=$(kaggle models instances versions create mateomangialomini/proto/pytorch/default -p "$PROTO_DIR" | tee /dev/tty | grep -oP 'models/\K[\w/]+$' | tr '[:upper:]' '[:lower:]')
echo "      → $VERSION_PROTO"
echo ""

# delete old ensemble weights and copy the new ones
echo "[5/6] Uploading ensemble weights dataset..."
rm notebook/ensemble_weights/ensemble_weights.npy
cp birdclef-2026/working/outputs/ensemble_weights.npy notebook/ensemble_weights/ensemble_weights.npy

# upload the dataset to Kaggle
kaggle datasets version -p notebook/ensemble_weights -m ""
echo "uploaded ensemble_weights.npy"

# delete old notebook and copy the new one
echo "[6/6] Preparing and pushing notebook..."
rm notebook/notebook.ipynb
cp notebook.ipynb notebook/notebook.ipynb

# set notebook to inference_mode by modifying the entry flags
sed -i 's/TRAIN_MODE      = True/TRAIN_MODE      = False/' notebook/notebook.ipynb
sed -i 's/INFERENCE_MODE  = False/INFERENCE_MODE  = True/' notebook/notebook.ipynb

# modify the paths referencing the models in the notebook 
sed -i "s|mateomangialomini/mlp/pytorch/default/[0-9]*/fold0_best_mlp|$VERSION_MLP/fold0_best_mlp|I" notebook/notebook.ipynb
sed -i "s|mateomangialomini/proto/pytorch/default/[0-9]*/fold0_best_proto|$VERSION_PROTO/fold0_best_proto|I" notebook/notebook.ipynb

# modifiy kernel-metadata.json to import new versions of the models
sed -i "s|mateomangialomini/mlp/pytorch/default/[0-9]*|$VERSION_MLP|I" notebook/kernel-metadata.json
sed -i "s|mateomangialomini/proto/pytorch/default/[0-9]*|$VERSION_PROTO|I" notebook/kernel-metadata.json

# upload and run the notebook on Kaggle
kaggle kernels push -p notebook

echo "================================================"
echo "                    Done ✓                      "
echo "  MLP   : $VERSION_MLP"
echo "  Proto : $VERSION_PROTO"
echo "================================================"
