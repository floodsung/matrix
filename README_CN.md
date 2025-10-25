<h1>
  <a href="#"><img alt="Forest" src="demo_gif/Forest.png" width="100%"/></a>
  </h1>

# MATRIX
MATRIX 是一个先进的仿真平台，集成了 **MuJoCo**、**Unreal Engine 5** 和 **CARLA**，为四足机器人研究提供高保真、交互式环境。其软件在环架构实现了逼真的物理效果、沉浸式视觉效果以及优化的仿真到现实迁移能力，助力机器人开发与部署。

  ---

  ## 📂 目录结构

  ```text
  ├── deps/                        # 第三方依赖
  │   ├── ecal_5.13.3-1ppa1~jammy_amd64.deb
  │   ├── mujoco_3.3.0_x86_64_Linux.deb
  │   ├── onnx_1.51.0_x86_64_jammy_Linux.deb
  │   └── zsibot_common*.deb
  ├── scripts/                     # 构建与配置脚本
  │   ├── build_mc.sh
  │   ├── build_mujoco_sdk.sh
  │   ├── download_uesim.sh
  │   ├── install_deps.sh
  │   └── modify_config.sh
  ├── src/
  │   ├── robot_mc/
  │   ├── robot_mujoco/
  │   ├── navigo/
  │   └── UeSim/
  ├── build.sh                     # 一键构建脚本
  ├── run_sim.sh                   # 仿真启动脚本
  └── README.md                    # 项目文档
  ```

  ---

  ## ⚙️ 环境依赖

  - **操作系统：** Ubuntu 22.04  
  - **推荐 GPU：** NVIDIA RTX 4060 或更高  
  - **Unreal Engine：** 集成（无需单独安装）  
  - **构建环境：**  
    - GCC/G++ ≥ C++11  
    - CMake ≥ 3.16  
  - **MuJoCo：** 3.3.0 开源版本（已集成）  
  - **远程控制器：** 必需（推荐：*Logitech Wireless Gamepad F710*）  
  - **Python 依赖：** `gdown`  

  ---

  ## 🚀 安装与构建

  1. **安装 LCM**
     ```bash
     sudo apt update
     sudo apt install -y cmake-qt-gui gcc g++ libglib2.0-dev python3-pip
     ```
     从 [LCM Releases](https://github.com/lcm-proj/lcm/releases) 下载源码并解压。

     构建与安装：
     ```bash
     cd lcm-<version>
     mkdir build
     cd build
     cmake ..
     make -j$(nproc)
     sudo make install
     ```
     > **注意：** 将 `<version>` 替换为实际解压的 LCM 目录名称。

  2. **下载 MATRiX 仿真器**

     - **方法 1：Google Drive**  
       [Google Drive 下载链接](https://drive.google.com/drive/folders/1JN9K3m6ZvmVpHY9BLk4k_Yj9vndyh8nT?usp=sharing)

       **通过 gdown 下载：**
       ```bash
       pip install gdown
       gdown https://drive.google.com/uc?id=1WMtHqtJEggjgTk0rOcwO6m99diUlzq_J
       ```

     - **方法 2：百度网盘**  
       [百度网盘链接](https://pan.baidu.com/s/1o8UEO1vUxPYmzeiiP9DYgg?pwd=hwqs)  

     - **方法 3：JFrog**  
       ```bash
       curl -H "Authorization: Bearer cmVmdGtuOjAxOjE3ODQ2MDY4OTQ6eFJvZVA5akpiMmRzTFVwWXQ3YWRIbTI3TEla"  -o "matrix.zip" -# "http://192.168.50.40:8082/artifactory/jszrsim/UeSim/matrix.zip"  
       ```
      > **注意：** 从云存储链接下载时，请确保选择最新版本以获得最佳兼容性和功能。

  3. **解压**
     ```bash
     unzip <downloaded_filename>
     ```

  4. **安装依赖**
     ```bash
     cd matrix
     ./build.sh
     ```
     *(此脚本将自动安装所有必需依赖。)*

  ---

  ## 🏞️ 仿真演示

  <div align="center">

  | **Map**         | **Demo Screenshot**                          | **Map**         | **Demo Screenshot**                          |
  |:---------------:|:-------------------------------------------:|:---------------:|:-------------------------------------------:|
  | **Venice**      | <img src="demo_gif/Venice.gif" alt="Matrix Demo Screenshot" width="350" height="200"/> | **Warehouse**   | <img src="demo_gif/whmap.gif" alt="Matrix Warehouse Demo" width="350" height="200"/> |
  | **Town10**      | <img src="demo_gif/Town10.gif" alt="Matrix Town Demo" width="350" height="200"/>       | **Yard**        | <img src="demo_gif/Yardmap.gif" alt="Matrix Yardmap Demo" width="350" height="200"/> |

  </div>

  > **注意：** 上述截图展示了用于机器人和强化学习实验的高保真 UE5 渲染效果。

  ---

  ## ▶️ 运行仿真

  <div align="center">
    <img src="demo_gif/Launcher.png" alt="Simulation Running Example" width="50%" />
  </div>

  ## 🐕 仿真设置指南

  1. **选择机器人类型**  
    选择仿真中使用的四足机器人类型。

  2. **选择环境**  
    选择所需的仿真环境或地图。

  3. **选择控制设备**  
    选择首选的控制设备：  
    - 游戏手柄控制
    - 键盘控制

  4. **启用无头模式（可选）**  
    切换 **无头模式** 选项以在无图形界面下运行仿真。

  5. **启动仿真**  
    点击 **启动仿真** 按钮开始仿真。

  在仿真运行过程中，如果 UE 界面处于激活状态，可按下 **ALT + TAB** 切出界面。  
  然后通过启动器上的 控制模式切换按钮，即可随时在手柄控制与键盘控制之间切换。



  ## 🎮 远程控制器说明（游戏手柄控制指南）

  | 动作                              | 控制器输入                        |
  |--------------------------------------|-----------------------------------------|
  | 站立 / 坐下                         | 按住 **LB** + **Y**                     |
  | 前进 / 后退 / 左移 / 右移            | **左摇杆**（上 / 下 / 左 / 右）         |
  | 左转 / 右转                         | **右摇杆**（左 / 右）                   |
  | 前跳                                | 按住 **RB** + **Y**                     |
  | 原地跳                              | 按住 **RB** + **X**                     |
  | 翻滚                                | 按住 **RB** + **B**                     |

  
  ## ⌨️ 远程控制器说明（键盘控制指南）

  | 动作                              | 控制器输入                        |
  |--------------------------------------|-----------------------------------------|
  | 站立                               | U                                       |
  | 坐下                               | 空格键                                 |
  | 前进 / 后退 / 左移 / 右移            | W / S / A / D                           |
  | 左转 / 右转                         | Q / E                                   |

  按 **V** 键在自由相机和机器人视角之间切换。  
  按住 **左键** 可临时切换到自由相机模式。

  ---

  ## 🔧 配置指南

  ### 调整传感器配置

  编辑：
  ```bash
  vim matrix/src/UeSim/jszr_mujoco_ue/Content/model/config/config.json
  ```

  示例片段：
  ```json
  "sensors": {
    "camera": {
      "position": { "x": 29.0, "y": 0.0, "z": 1.0 },
      "rotation": { "roll": 0.0, "pitch": 15.0, "yaw": 0.0 },
      "height": 1080,
      "width": 1920,
      "sensor_type": "rgb",
      "topic": "/image_raw/compressed"
    },
    "depth_sensor": {
      "position": { "x": 29.0, "y": 0.0, "z": 1.0 },
      "rotation": { "roll": 0.0, "pitch": 15.0, "yaw": 0.0 },
      "height": 480,
      "width": 640,
      "sensor_type": "depth",
      "topic": "/image_raw/compressed/depth"
  },
  "lidar": {
    "position": { "x": 13.011, "y": 2.329, "z": 17.598 },
    "rotation": { "roll": 0.0, "pitch": 0.0, "yaw": 0.0 },
    "sensor_type": "mid360",
    "topic": "/livox/lidar"
  }
}
```

- 根据需要调整 **位姿** 和 **传感器数量**  
- 移除未使用的传感器以提高 **UE FPS 性能**

---

## 📡 传感器数据后处理

- 深度相机以 **32FC1 编码** 输出图像为 `sensor_msgs::msg::Image`。
- 要获取灰度深度图像，可使用以下代码片段：

```bash
  void callback(const sensor_msgs::msg::Image::SharedPtr msg)
  {
    cv::Mat depth_image;
    depth_image = cv::Mat(HEIGHT, WIDTH, CV_32FC1, const_cast<uchar*>(msg->data.data()));
  }
```




  ## 📡 在 RViz 中可视化传感器数据

  要在 RViz 中可视化传感器数据：

  1. **按照上述步骤启动仿真**。
  2. **启动 RViz**：
    ```bash
    rviz2
    ```
  3. **加载配置文件**：  
    在 RViz 中打开 `rviz/matrix.rviz` 以获得预配置视图。

  <div align="center">
    <img src="./demo_gif/rviz2.png" alt="RViz Visualization Example" width="1280" height="720"/>
  </div>
  
  > **提示：** 确保您的 ROS 环境已正确配置，并且相关主题正在发布。



  ---
