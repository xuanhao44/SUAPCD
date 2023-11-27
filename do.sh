# do 脚本
## 可直接运行
## 运行前请先 tmux new -s train

#!/bin/bash
set -euxo pipefail

# echo 0 | tee /sys/module/nvidia/drivers/pci:nvidia/*/numa_node
export TF_CPP_MIN_LOG_LEVEL=2

DATA_DIR="$HOME/assessment_plan_modeling/data"
TFRECORDS_PATH="${DATA_DIR}/ap_parsing_tf_examples/$(date +%Y%m%d)"
PYTHONPATH=$(pwd) python assessment_plan_modeling/ap_parsing/data_gen_main.py \
  --input_note_events="${DATA_DIR}/notes.csv" \
  --input_ratings="${DATA_DIR}/all_model_ratings.csv" \
  --output_path=${TFRECORDS_PATH} \
  --vocab_file="${DATA_DIR}/word_vocab_25K.txt" \
  --section_markers="assessment_plan_modeling/note_sectioning/data/mimic_note_section_markers.json" \
  --n_downsample=100 \
  --max_seq_length=2048

EXP_TYPE="ap_parsing"
CONFIG_DIR="assessment_plan_modeling/ap_parsing/configs"
MODEL_DIR="${DATA_DIR}/models/model_$(date +%Y%m%d-%H%M)"

TRAIN_DATA="${TFRECORDS_PATH}/train_rated_nonaugmented.tfrecord*"
VAL_DATA="${TFRECORDS_PATH}/val_set.tfrecord*"
PARAMS_OVERRIDE="task.use_crf=true"
PARAMS_OVERRIDE="${PARAMS_OVERRIDE},task.train_data.input_path='${TRAIN_DATA}'"
PARAMS_OVERRIDE="${PARAMS_OVERRIDE},task.validation_data.input_path='${VAL_DATA}'"
PARAMS_OVERRIDE="${PARAMS_OVERRIDE},trainer.train_steps=5000"

time PYTHONPATH=$(pwd) python assessment_plan_modeling/ap_parsing/train.py \
  --experiment=${EXP_TYPE} \
  --config_file="${CONFIG_DIR}/base_ap_parsing_model_config.yaml" \
  --config_file="${CONFIG_DIR}/base_ap_parsing_task_config.yaml" \
  --params_override=${PARAMS_OVERRIDE} \
  --mode=train_and_eval \
  --model_dir=${MODEL_DIR} \
  --alsologtostderr > ModelTrain_Out_$(date +%Y%m%d-%H%M).txt 2> ModelTrain_Error_$(date +%Y%m%d-%H%M).txt