#!/bin/bash
UE_TRUE_SCRIPT_NAME=$(echo \"$0\" | xargs readlink -f)
UE_PROJECT_ROOT=$(dirname "$UE_TRUE_SCRIPT_NAME")
chmod +x "$UE_PROJECT_ROOT/jszr_mujoco_ue/Binaries/Linux/jszr_mujoco_ue-Linux-Shipping"
"$UE_PROJECT_ROOT/jszr_mujoco_ue/Binaries/Linux/jszr_mujoco_ue-Linux-Shipping" jszr_mujoco_ue "$@" 
