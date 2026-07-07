# MATRiX — 机器人仿真平台 v1.0.0 Preview (Windows / Linux)

MATRiX 是基于 Unreal Engine 构建的高保真机器人仿真平台，内置 MuJoCo 物理引擎，支持多种主流机器人模型、多传感器模拟与多场景切换，通讯层采用 **Zenoh** 协议，即下即用，无需 ROS 环境。

---

## 目录

- [系统要求](#系统要求)
- [目录结构](#目录结构)
- [快速开始](#快速开始)
- [机器人模型](#机器人模型)
- [场景列表](#场景列表)
- [传感器配置](#传感器配置)
- [通讯接口](#通讯接口)
- [Python 工具](#python-工具)
- [mc_python 运动控制器](#mc_python-运动控制器)
- [高级配置（手动编辑）](#高级配置手动编辑)
- [常见问题](#常见问题)

---

## 系统要求

| 项目 | 最低配置 | 推荐配置 |
|------|---------|---------|
| 操作系统 | Windows 64-bit / Linux 64-bit | Windows 64-bit / Linux 64-bit |
| CPU | 6 核 @ 2.5 GHz | 12 核 @ 3.5 GHz |
| 内存 | 16 GB RAM | 32 GB RAM |
| GPU | NVIDIA GTX 1070 (8 GB VRAM) | NVIDIA RTX 3080 / 4080 |
| 显卡驱动 | Windows: NVIDIA Driver ≥ 526.x<br>Linux: NVIDIA Driver ≥ 535.x | 最新版 |
| 磁盘空间 | 20 GB 可用空间 | SSD 50 GB |
| Python（工具可选） | 3.10+ | 3.11 |

> **注意**：Windows 版本使用 DirectX 12 / Vulkan 后端，Linux 版本使用 Vulkan 后端，请确保显卡驱动为最新版本。

---

## 目录结构

```
MATRiX_v1.0.0_Preview/
├── README.md
├── Tools/                              # Python 辅助工具
│   ├── zenoh_sensor_receiver.py        # 传感器数据接收与可视化
│   └── zenoh_topic_monitor.py          # Zenoh 话题监控与统计
└── Windows/                            # 仿真平台主体
    ├── Engine/                         # Unreal Engine 运行时
    └── UeSim/
        ├── Binaries/Win64/
        │   └── UeSim.exe               # ★ 主程序入口
        ├── Content/
        │   └── model/
        │       ├── config/
        │       │   ├── config.json     # ★ 主配置文件
        │       │   └── sensors/        # 传感器预设配置
        │       ├── go2/                # Unitree Go2 模型
        │       ├── h1/                 # Unitree H1 人形机器人
        │       ├── xgb/                # 宇树 XGB 机器人
        │       └── ...                 # 更多机器人模型
        └── Saved/
            ├── Config/Windows/
            │   └── GameUserSettings.ini  # 画质/分辨率设置
            └── DLCs/                     # 场景包（.pak 文件）
```

---

## 快速开始

### 前置步骤：下载MATRiX和地图DLC

Linux 下载地址：https://pan.baidu.com/s/1I87hQ9C8XzIGXgbyWk3i9A?pwd=6sth

Windows 下载地址：https://pan.baidu.com/s/1JTMi2H8WMC2T8_8fbspjzA?pwd=s9iy
- 从云盘下载地图 DLC 到 `Windows/UeSim/Saved/DLCs` 文件夹，地图数量按需下载

下载后将 `.pak` 文件放入上述目录，重启仿真器以加载新场景。

### 第一步：启动仿真器

直接双击运行主程序，无需安装：

```
Windows/UeSim/Binaries/Win64/UeSim.exe
```

或通过命令行启动（支持更多参数）：

```powershell
cd Windows\UeSim\Binaries\Win64
.\UeSim.exe
```

首次启动会加载默认场景与默认机器人（`xgb`），稍等片刻后仿真界面即可显示。

---

### 第二步：在界面中选择机器人与地图

仿真器启动后，主界面左侧显示配置面板，所有设置均可通过图形界面完成，无需手动编辑文件。

**选择机器人：**
在面板的 **Robot** 下拉列表中选择目标机器人型号（如 `go2`、`xgb` 等），点击确认后仿真场景中的机器人将立即切换。

**选择地图：**
在面板的 **Map / World** 下拉列表中选择目标场景，点击加载后仿真器将切换至对应环境。所有已安装的 DLC 场景包均会出现在列表中。

**调整初始位置：**
在面板中可直接输入机器人的初始坐标（X / Y / Z）完成位置设置。

> **运动控制（mc_python）：** 选好机型后，如需用 RL 策略驱动机器人运动（行走、翻滚、跳跃等），请参见「[mc_python 运动控制器](#mc_python-运动控制器)」章节，完成 Zenoh Router 与控制器的启动配置。

---

### 第三步：在界面中配置传感器

在配置面板的 **Sensors** 区域，可通过图形界面为机器人添加、删除和调整传感器：

- **传感器类型**：从下拉菜单选择 RGB 摄像头、深度摄像头、激光雷达、全景摄像头等
- **安装位置**：直接填写传感器相对于机器人基座的 X / Y / Z 偏移（米）
- **安装角度**：填写 Roll / Pitch / Yaw 旋转角（度）
- **分辨率与频率**：设置图像宽高（像素）和发布频率（Hz）
- **话题名**：设置该传感器数据发布的 Zenoh 话题名称

配置修改后点击 **Apply** 或 **Restart** 按钮使设置生效。

> 所有界面配置均自动保存至 `Windows/UeSim/Content/model/config/config.json`，无需手动编辑文件。

---

### 第四步：安装 Python 工具依赖（可选）

如需使用传感器可视化或话题监控工具，请先安装依赖：

```powershell
pip install eclipse-zenoh opencv-python numpy
```

---

### 第五步：接收传感器数据

仿真器运行后，在 `Tools/` 目录下运行：

```powershell
cd Tools
python zenoh_sensor_receiver.py
```

成功后将弹出 OpenCV 窗口，实时显示仿真器输出的图像数据。

---

### 第六步：监控话题状态

```powershell
cd Tools
python zenoh_topic_monitor.py
```

终端将以表格形式持续刷新当前所有活跃 Zenoh 话题的频率、延迟与数据大小。

---

## 机器人模型

机器人型号在仿真器界面的 **Robot** 下拉列表中选择，以下为全部支持的机器人标识与对应描述。

| 模型标识 | 机器人描述 | mc_python 运控支持 |
|---------|-----------|------------------|
| `go2`   | Unitree Go2 四足机器人 | 暂不支持 |
| `go2w`  | Unitree Go2 轮式版本 | 暂不支持 |
| `xgb`   | 智身科技 XGB 机器人（默认） | ✅ 已支持 |
| `xgw`   | 智身科技 XGW 机器人 | 暂不支持 |
| `xxg`   | 智身科技 XXG 机器人 | 暂不支持 |
| `zgws`  | 智身科技 ZGWS 机器人 | 暂不支持 |

> mc_python 当前仅支持 `xgb`，更多机型支持将在后续版本中陆续更新。


---

## 场景列表

场景在仿真器界面的 **Map / World** 下拉列表中选择。场景以 DLC `.pak` 包形式分发，位于 `Windows/UeSim/Saved/DLCs/`，仿真器启动时自动加载所有已存在的包。添加或删除 `.pak` 文件后重启仿真器，列表将自动更新。

| 场景包文件 | 场景描述 |
|-----------|---------|
| `ApartmentWorldBundle.pak` | 室内公寓场景 |
| `OfficeWorldBundle.pak` | 办公室场景 |
| `HouseWorldBundle.pak` | 室内住宅场景（版本 1） |
| `House2WorldBundle.pak` | 室内住宅场景（版本 2） |
| `MeetRoomWorldBundle.pak` | 会议室场景 |
| `YardWorldBundle.pak` | 室外庭院场景 |
| `Town10WorldBundle.pak` | 城市街道场景 |
| `Town10ZombieBundle.pak` | 末日城市场景 |
| `CaliWorldBundle.pak` | 仿加州街区场景 |
| `VeniceWorldBundle.pak` | 仿威尼斯水城场景 |
| `BatuluWorldBundle.pak` | Batulu 场景 |
| `MoonWorldBundle.pak` | 月球表面场景 |
| `RunningWorldBundle.pak` | 跑步训练场景 |
| `CrowdWorldBundle.pak` | 人群模拟场景 |
| `SceneWorldBundle.pak` | 通用测试场景 |
| `CustomWorldBundle.pak` | 自定义场景 |
| `3DGSWorldBundle.pak` | 3D Gaussian Splatting 真实场景重建 |
| `IROSFlatWorldBundle.pak` | IROS 平地竞赛场景 |
| `IROSSlopedWorldBundle.pak` | IROS 坡面竞赛场景 |
| `IROSFlatWorld2025Bundle.pak` | IROS 2025 平地场景 |
| `IROSSloppedWorld2025Bundle.pak` | IROS 2025 坡面场景 |


---

## 传感器配置

传感器通过仿真器界面的 **Sensors** 面板进行图形化配置，支持同时挂载多个传感器。以下各小节说明每类传感器的可配置参数，对应界面中的输入字段。

> 如需直接编辑配置文件，所有传感器参数保存在 `Windows/UeSim/Content/model/config/config.json` 的 `sensors` 字段下，以及 `sensors/` 子目录中的预设文件。

### RGB 摄像头

```json
"camera": {
  "sensor_type": "rgb",
  "topic": "/front_camera/image/compressed",
  "frequency": 10,
  "position": { "x": 0.18, "y": 0.0, "z": 0.3 },
  "rotation": { "roll": 0, "pitch": 0, "yaw": 0 },
  "height": 1080,
  "width": 1920,
  "fov": 120
}
```

### 深度摄像头

```json
"depth_sensor": {
  "sensor_type": "depth",
  "topic": "/front_depth/image",
  "frequency": 10,
  "position": { "x": 0.18, "y": 0.0, "z": 0.3 },
  "rotation": { "roll": 0, "pitch": 0, "yaw": 0 },
  "height": 480,
  "width": 640,
  "fov": 120,
  "cloudmode": false
}
```

### 激光雷达 (LiDAR)

```json
"lidar": {
  "sensor_type": "mid360",
  "topic": "/front_lidar",
  "frequency": 10,
  "position": { "x": 0.18, "y": 0.0, "z": 0.3 },
  "rotation": { "roll": 0, "pitch": 0, "yaw": 0 },
  "draw_points": false,
  "random_scan": false
}
```

### 全景摄像头

使用预设配置文件 `sensors/config_panorama.json`，支持全景 RGB 与全景深度：

```json
"panoramargb": {
  "sensor_type": "panoramargb",
  "topic": "/panoramargb/front_camera/compressed",
  "frequency": 1,
  "position": { "x": 0.0, "y": 0.0, "z": 0.3 },
  "rotation": { "roll": 0, "pitch": 0, "yaw": 0 },
  "height": 256
}
```

### 广角摄像头

使用预设配置文件 `sensors/config_wideanglecamera.json`：

```json
"wargb": {
  "sensor_type": "wargb",
  "topic": "/wargb/front_left/compressed",
  "frequency": 1,
  "position": { "x": 0.27, "y": 0.0, "z": 0.5 },
  "rotation": { "roll": 0, "pitch": 0, "yaw": 0 },
  "height": 540,
  "width": 960,
  "fov": 80
}
```

### 传感器通用字段说明

| 字段 | 类型 | 说明 |
|------|------|------|
| `sensor_type` | string | 传感器类型：`rgb` / `depth` / `mid360` / `panoramargb` / `panoramadepth` / `wargb` / `wadepth` |
| `topic` | string | Zenoh 发布的 key 表达式（话题名） |
| `frequency` | number | 发布频率（Hz） |
| `position` | object | 相对于机器人基座的位置偏移（米） |
| `rotation` | object | 相对于机器人基座的旋转（度），roll / pitch / yaw |
| `height` / `width` | number | 图像分辨率（像素） |
| `fov` | number | 水平视场角（度） |

---

## 通讯接口

MATRiX 使用 **Zenoh** 协议进行所有数据通讯，默认在本机 `tcp/0.0.0.0:7447` 监听。

### 默认端口

| 端口 | 用途 |
|------|------|
| `25001` | 机器人状态上报（`state_port`） |
| `25002` | 机器人控制指令接收（`cmd_port`） |
| `7447` | Zenoh Router 默认监听端口 |

### 话题命名规则

传感器数据话题均以 `rt/` 为前缀（ROS2 兼容格式），例如：

- `rt/front_camera/image/compressed` — 前置 RGB 图像（CompressedImage CDR 格式）
- `rt/front_depth/image` — 前置深度图像
- `rt/front_lidar` — 前置激光雷达点云（PointCloud2 CDR 格式）
- `mujoco/**` — MuJoCo 物理状态数据

### 跨机器连接示例

在另一台机器上运行工具，连接到仿真器所在主机（IP 示例：`192.168.1.100`）：

```powershell
python zenoh_sensor_receiver.py --mode client --connect tcp/192.168.1.100:7447
python zenoh_topic_monitor.py --mode client --connect tcp/192.168.1.100:7447
```

---

## Python 工具

工具位于 `Tools/` 目录，需要 Python 3.10+。

### 安装依赖

```powershell
pip install eclipse-zenoh opencv-python numpy
```

---

### zenoh_sensor_receiver.py — 传感器数据接收器

订阅仿真器发布的传感器数据，自动识别图像并弹出 OpenCV 显示窗口，对点云和其他数据打印元信息。

#### 基本用法

```powershell
# 默认模式（本机 Router，监听 tcp/0.0.0.0:7447）
python zenoh_sensor_receiver.py

# 客户端模式，连接指定 Router
python zenoh_sensor_receiver.py --mode client --connect tcp/127.0.0.1:7447

# 仅订阅激光雷达话题
python zenoh_sensor_receiver.py --key "rt/front_lidar"

# 深度图启用伪彩色显示
python zenoh_sensor_receiver.py --show-depth

# 订阅 MuJoCo 所有话题
python zenoh_sensor_receiver.py --key "mujoco/**"
```

#### 参数列表

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `--key` | `rt/**` | Zenoh key 表达式，支持通配符 |
| `--mode` | `router` | Zenoh 会话模式：`router` / `client` / `peer` |
| `--connect` | — | 连接端点，可多次指定 |
| `--listen` | — | 监听端点，可多次指定 |
| `--show-depth` | 关闭 | 对深度类 PNG 图像应用伪彩色 |
| `--print-interval` | `1.0` | 非图像话题的打印节流间隔（秒） |
| `--max-text` | `240` | 文本 payload 最大打印字符数 |
| `--window-prefix` | `sensor` | OpenCV 窗口名前缀 |

---

### zenoh_topic_monitor.py — 话题监控器

以表格形式实时显示所有活跃 Zenoh 话题的消息频率、payload 大小及时间戳延迟统计。

#### 基本用法

```powershell
# 默认监控所有话题
python zenoh_topic_monitor.py

# 客户端模式
python zenoh_topic_monitor.py --mode client --connect tcp/127.0.0.1:7447

# 仅监控 MuJoCo 话题，0.5 秒刷新
python zenoh_topic_monitor.py --key "mujoco/**" --interval 0.5

# 按话题名排序
python zenoh_topic_monitor.py --sort name
```

#### 参数列表

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `--key` | `**` | 监控的 key 表达式 |
| `--mode` | `router` | Zenoh 会话模式 |
| `--connect` | — | 连接端点 |
| `--listen` | — | 监听端点 |
| `--interval` | `1.0` | 表格刷新间隔（秒） |
| `--window` | `5.0` | 计算 Hz 的滑动窗口时长（秒） |
| `--max-topics` | `50` | 最多显示话题数 |
| `--sort` | `hz` | 排序字段：`hz` / `name` / `last` |
| `--no-clear` | 关闭 | 禁止清屏，保留历史输出 |
| `--show-empty` | 关闭 | 保留窗口内无消息的话题行 |

---

### 启动顺序

MATRiX 内置 Zenoh Router，启动仿真器后即自动提供通讯服务，无需单独安装或运行 `zenohd`：

```powershell
# 第一步：启动 MATRiX，在 Robot 下拉列表中选好机型（如 xgb）

# 第二步：启动运控程序


### 手柄输入方式

| 方式 | 启动命令 | 说明 |
|------|---------|------|
| 物理手柄（Xbox 兼容） | `python run.py --robot xgb` | auto 模式自动检测 |
| Qt 屏幕虚拟手柄 | `python run.py --robot xgb --virtual-gamepad on` | 需 `pip install PySide6` |
| UDP 远程手柄 | `python run.py --robot xgb --udp-gamepad-port 7448` | 网络远程控制 |

### 关键控制指令（以 XGB 为例）

| 组合键 | 动作 | 说明 |
|--------|------|------|
| `LB + RB` | Passive | 零力矩安全停止（kp=kd=0） |
| `LB + Y` | Stand up | 起立 |
| `LB + A` | RL Walk | RL mix 行走策略 |
| `LB + B` | Balance stand | 平衡站立 |
| `RB + X` | Jump | 跳跃 |
| `RB + Y` | Front flip | 前空翻 |
| `RB + B` | Back flip | 后空翻 |
| 左摇杆 X/Y | 线速度 | 前进 / 横移 |
| 右摇杆 X | 偏航角速度 | 转向 |

### 安全操作流程

```
上电 / 重置  →  Passive (LB+RB)  →  确认稳定  →  Stand (LB+Y)  →  策略 (LB+A/B)
```

> Passive 为真零力矩（kp=kd=0），切换前务必确认机器人处于安全姿态。首次联调建议先运行 `python run.py --dry-run --print-gamepad` 验证手柄链路，不连接 MATRiX。

---

## mc_python 运动控制器

本节简要说明如何启动与配置 `matrix_mc` / `matrix_mc_unreal` 运控程序（简称运控），参照随编译输出的 `MATRiX_MC/matrix_mc_usage.md`。

### 1. 运行目录中应包含的文件

运行程序的目录应至少包含：

```
matrix_mc_unreal.exe     # Windows 运控程序
matrix_mc_unreal         # Linux 运控程序
matrix_mc.conf           # 运行配置文件
matrix_mc_usage.md       # 使用说明（本文件说明来源）
zenohc.dll / libzenohc.so# Zenoh 运行库
onnx_model_crypto/       # 加密模型目录（可选）
```

### 2. 运行前准备

1. 启动 Unreal 仿真，并确认仿真侧正在发布 `mujoco/state`、订阅 `mujoco/cmd`。
2. 确保运控与 Unreal 使用相同的 Zenoh endpoint（默认 `tcp/127.0.0.1:7447`）。
3. 确保 `matrix_mc.conf` 在当前工作目录或与可执行文件同目录。
4. 确认 `robot` 配置与 Unreal 场景中加载的机器人型号一致。

如需在启动前指定远端 endpoint：

Windows PowerShell:

```powershell
$env:MATRIX_MC_ZENOH_ENDPOINT="tcp/192.168.1.10:7447"
```



### 3. 启动运控程序

启动时请使用运行目录下的可执行文件；启动参数不再用于修改机器人型号或手柄端口，这些请写入 `matrix_mc.conf`：

Windows PowerShell:

```powershell
cd C:\path\to\matrix_mc\build\Release
.\matrix_mc_unreal.exe
```

常用配置说明：

| 配置项 | 示例 | 说明 |
| --- | --- | --- |
| `robot` | `XXG` | 机器人型号，必须与 Unreal 场景一致 |
| `rate_hz` | `500` | 主控制循环频率（Hz） |
| `gamepad_input` | `hardware` / `virtual` / `udp` | 手柄输入来源 |
| `gamepad_udp_port` | `7447` | `udp` 模式的端口 |
| `allow_scripted_stunts` | `false` | 模型不可用时是否允许脚本动作 |

修改后需重启运控程序生效。

可选的 `robot` 值包括：`XGB` `XGW` `ZGWS` 等。

### 6. 手柄控制

`gamepad_input` 决定手柄来源：

```
gamepad_input = hardware  # 读取实体手柄
gamepad_input = virtual   # 打开内置虚拟手柄窗口
gamepad_input = udp       # 监听外部 UDP JSON 手柄
```

Linux 实体手柄默认读取 `/dev/input/js0`，可用 `GAMEPAD_DEVICE=/dev/input/js1` 切换。

常用按键示例：

```
LB + Y      起身（一次性触发）
LB + RB     被动模式（停止输出力矩）
LB + X      关节 PD（保持关节位置）
LB + B      平衡站立
Start       进入行走模式
左摇杆      前后/左右速度
右摇杆 X    转向
RB + X/Y/B  跳跃 / 翻转 等动作
```
---

## 高级配置（手动编辑）

以下内容供需要批量修改、脚本自动化或超出界面功能的高级用法参考。正常使用时通过仿真器界面操作即可，无需手动编辑这些文件。

### config.json 完整字段说明

```json
{
  "robot": {
    "robot_type": "xgb",          // 机器人类型，见"机器人模型"章节
    "weapon": "",                  // 武器配置（保留字段）
    "position": {                  // 机器人初始位置（米）
      "x": 0.001,
      "y": 0.001,
      "z": 0.001
    },
    "state_port": 25001,           // 状态上报端口
    "cmd_port": 25002,             // 控制指令端口
    "EgoView": true,               // 是否启用第一人称视角
    "synchronous_mode": false,     // 同步模式（true = 锁步仿真）
    "synchronous_frequency": 10,   // 同步模式下的步进频率（Hz）
    "mujoco_running": false,       // 是否由外部 MuJoCo 驱动
    "sensors": { ... }             // 传感器配置，见"传感器配置"章节
  }
}
```

### GameUserSettings.ini — 画质设置

位于 `Windows/UeSim/Saved/Config/Windows/GameUserSettings.ini`，可手动调整：

```ini
[ScalabilityGroups]
sg.ResolutionQuality=100    ; 渲染分辨率比例（0-100）
sg.TextureQuality=3         ; 贴图质量（0-3）
sg.ShadowQuality=3          ; 阴影质量（0-3）
sg.PostProcessQuality=3     ; 后期处理质量（0-3）
```

---

## 常见问题

**Q: 启动后黑屏或崩溃**
- 检查显卡驱动是否为最新版本（需支持 DX12）
- 确认显存 ≥ 8 GB
- 以管理员权限运行 `UeSim.exe`

**Q: Python 工具提示 `ModuleNotFoundError: No module named 'zenoh'`**
- 运行 `pip install eclipse-zenoh` 安装 Zenoh Python SDK

**Q: 工具运行后没有任何话题输出**
- 确认仿真器已正常启动
- 默认工具以 Router 模式监听 `tcp/0.0.0.0:7447`，与仿真器在同一台机器时无需额外配置
- 若在另一台机器上运行，使用 `--mode client --connect tcp/<仿真器IP>:7447`

**Q: 如何更换场景**
- 仿真器内通过 UI 菜单切换场景，或在启动参数中指定 Map
- 添加/删除 `Saved/DLCs/` 内的 `.pak` 文件可控制可用场景

**Q: 深度图显示为纯白色**
- 使用 `--show-depth` 参数启用伪彩色映射：`python zenoh_sensor_receiver.py --show-depth`

**Q: 如何开启 MuJoCo 物理仿真**
- 在 `config.json` 中将 `"mujoco_running"` 设为 `true`，并通过外部 MuJoCo 控制器连接 `cmd_port`

**Q: 如何自定义机器人模型**
- 将 MuJoCo MJCF 文件放入 `Windows/UeSim/Content/model/custom/`
- 在 `config.json` 中将 `robot_type` 设为 `"custom"`

**Q: mc_python 启动后仿真器中的机器人没有响应**
- 确认 MATRiX 仿真器已正常启动（内置 Zenoh Router 随仿真器一同启动）
- 确认 `--robot` 参数与 MATRiX 界面 Robot 下拉中选择的机型一致（如都选 `xgb`）
- 用 `python Scripts/zenoh_topic_monitor.py` 检查 `mujoco/**` 话题是否有数据输出

**Q: mc_python 连接远端 MATRiX（跨机器）**
- 在 mc_python 侧指定仿真器所在 IP：`python run.py --robot xgb --zenoh-endpoint tcp/<MATRiX_IP>:7447`
- 确认防火墙已对 TCP 7447 端口放行

**Q: 机器人起立后立即倒下**
- 标准流程：先发 Passive（`LB+RB`）确认机器人静止，再发 Stand（`LB+Y`），稳定后再切行走策略
- 检查 ONNX 模型文件是否完整（`mc_python/assets/onnx_model/<robot>/`）

**Q: 使用 mc_python 的 UDP 远程手柄控制**
- 接收端：`python run.py --robot xgb --udp-gamepad-port 7448`
- 发送端：`python Scripts/send_gamepad_cmd.py --host <接收端IP> stand`
- 常用预置指令：`passive` / `stand` / `walk` / `balance` / `jump`

---

## 版本信息

| 项目 | 信息 |
|------|------|
| 版本 | v1.0.0 Preview |
| 平台 | Windows 64-bit / Linux 64-bit |
| 渲染引擎 | Unreal Engine |
| 物理引擎 | MuJoCo |
| 通讯协议 | Zenoh |
| 发布时间 | 2026 |
