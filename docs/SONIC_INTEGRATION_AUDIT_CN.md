# Matrix 原生场景与 SONIC 集成审计

## 范围

本审计只评估 Matrix 0.1.2 自带的原生地图，不导入 AUE 当前的
`overworld` 场景。目标是判断 Matrix 能否承载 G1 29 自由度 SONIC，重点考察：

1. 视觉还原度
2. 物理还原度
3. SONIC 50 Hz 闭环能否稳定持续

审计基线为 Matrix `918fae3`，工作分支为
`research/sonic-integration-audit`。

## 原生场景数量

Matrix 0.1.2 发布清单包含 19 个可选地图包：18 个正式场景和 1 个
`CustomWorld` 模板。Base 包中还带有一个不在当前启动菜单中的
`EmptyWorld`，所以按发布资产计算共有 20 个地图资产。

| 启动 ID | 菜单/文档名 | UE 地图 | MuJoCo 场景 |
| --- | --- | --- | --- |
| 0 | CustomWorld | CustomWorld | scene_terrain_custom.xml |
| 1 | Warehouse | SceneWorld | scene_terrain_wh.xml |
| 2 | Town10World | Town10World | scene_terrain_t10.xml |
| 3 | YardWorld | YardWorld | scene_terrain_yard.xml |
| 4 | CrowdWorld | CrowdWorld | scene_terrain_crowd.xml |
| 5 | VeniceWorld | VeniceWorld | scene_terrain_venice.xml |
| 6 | HouseWorld | HouseWorld | scene_terrain_house.xml |
| 7 | RunningWorld | RunningWorld | scene_terrain_rw.xml |
| 8 | Town10Zombie | Town10Zombie | scene_terrain_zombie.xml |
| 9 | IROSFlatWorld | IROSFlatWorld | scene_terrain_flat.xml |
| 10 | IROSSlopedWorld | IROSSlopedWorld | scene_terrain_sloped.xml |
| 11 | IROSFlatWorld2025 | IROSFlatWorld2025 | scene_terrain_flat25.xml |
| 12 | IROSSloppedWorld2025 | IROSSloppedWorld2025 | scene_terrain_sloped25.xml |
| 13 | OfficeWorld | OfficeWorld | scene_terrain_office.xml |
| 14, 16, 17 | 3DGSWorld | 3DGSWorld | 3dgs.xml |
| 15 | MoonWorld | MoonWorld | scene_terrain_moon_dynamic.xml |
| 20 | Cali Room | CaliWorld | scene_terrain_cali.xml |
| 21 | Home | ApartmentWorld | scene_terrain_apart2.xml |
| 22 | Laboratory | MeetRoomWorld | scene_terrain_meet.xml |

`16` 和 `17` 都是 `3DGSWorld` 的别名，不是额外地图。完整包大小、SHA256、
预览图和物理代理统计见
`research/sonic_integration/native_scenes.json`。

## 当前静态结论

### 视觉

Matrix 使用 Unreal Engine 5/CARLA 渲染。原生预览中，`Town10World`、
`Warehouse`、`ApartmentWorld` 和 `3DGSWorld` 的材质、光照和场景密度明显高于
当前 AUE 小场景，适合做视觉基线。但预览图只能证明离线展示效果，不能证明
目标 GPU 上的持续帧率、传感器一致性或交互性。

### 物理

Matrix 的 UE 视觉与 MuJoCo 物理是两套场景表示。历史公开 XML
`f5406c5c97642d66c80d686bdde2929966fa643e` 显示，大多数复杂视觉场景使用
静态 box/cylinder 代理：

| 场景 | MuJoCo 环境 geom | 主要代理 | 动态物体 |
| --- | ---: | --- | ---: |
| 3DGSWorld | 11 | 1 plane + 10 box | 0 |
| Warehouse | 210 | 201 box + 8 cylinder | 0 |
| Town10World | 869 | 686 box + 173 cylinder + 9 mesh | 0 |
| VeniceWorld | 1276 | 1172 box + 103 cylinder | 0 |
| CrowdWorld | 131 | 130 cylinder | 0 |
| OfficeWorld | 146 | 145 box | 0 |
| MoonWorld | 256 | 256 动态 box | 256 |

因此，Matrix 的视觉复杂度不能直接等同于物理复杂度。特别是 3DGS 场景，当前
证据只支持粗碰撞导航，不支持桌面物体级的精细抓取和可交互性。0.1.2 当前 XML
需要在 release 安装后再次核对，历史统计不能替代运行验收。

### 频率

当前公开配置和启动脚本的默认频率是：

| 链路 | 默认值 |
| --- | ---: |
| UE 最大渲染帧率 | 30 FPS |
| 机器人视觉同步 | 10 Hz |
| RGB / Depth / LiDAR 发布 | 10 Hz |
| MuJoCo 模型 timestep | 需按 0.1.2 运行资产复核 |
| SONIC 低层控制目标 | 50 Hz |

MuJoCo 内部能跑得快，不代表 UE 同步和相机也能达到 50 Hz。验收必须分别记录
physics tick、lowstate、lowcmd apply、UE render 和传感器发布频率。

## G1/SONIC 阻塞项

0.1.2 的 `robot_mujoco` 是 x86_64 闭源二进制。它链接 eCAL/Protobuf，并使用
`RobotCmd`、`RobotState` 和 `VisualData`。公开安装包中的 `RobotCmd` 固定为
四足语义字段：

```text
q_des_abad / hip / knee / foot
qd_des_abad / hip / knee / foot
kp_abad / hip / knee / foot
kd_abad / hip / knee / foot
tau_abad / hip / knee / foot
```

这不是 G1 29 自由度的通用关节数组。现有 custom URDF 流程还固定使用
`CustomWorld`，未知机器人会回退到 XG 四足控制配置。结论是：G1 模型可能可以
被转换成 MuJoCo XML，但现有运行时控制桥不能直接接 SONIC 29 自由度 lowstate /
lowcmd。

要继续集成，至少需要 Matrix 上游提供以下之一：

1. 通用 N 自由度状态/指令协议和关节名映射
2. `robot_mujoco`/UE 同步层源码或正式插件 API
3. 可验证的 G1/H1 humanoid runtime，而不只是历史模型文件

首轮机器人导入使用 SONIC 仓库的 canonical `g1_29dof.urdf`，不携带 AUE
场景。该模型有 39 个 link、38 个 joint，其中 29 个可动关节；63 个 mesh 引用在
源目录中均可解析。这可以验证 Matrix 的 URDF/MJCF 转换能力，但不能绕过上述
运行时协议限制。

## 许可证边界

Matrix 代码仓库使用 BSD-3-Clause。这个许可证允许修改和再分发代码及其已授权
二进制，但不能自动证明每个 UE/CARLA 地图、第三方素材或 3DGS 扫描数据都允许
用于我们的开放世界游戏并再次发布。正式复用场景前，需要为每个地图补齐来源、
作者、许可证、商业使用和再分发许可；当前 release manifest 只有包名、大小和
校验值，没有逐资产许可证清单。

## 运行验收计划

TRNA 是首轮运行机：Ubuntu 22.04 x86_64、RTX 5080 Laptop 16 GB。安装和实验
固定在 tmux：

```bash
ssh trna-zt
tmux attach -t matrix-sonic-eval
```

代表性原生场景：

| 场景 | 用途 |
| --- | --- |
| IROSFlatWorld | 低视觉负载下的物理/控制频率上限 |
| CaliWorld | 小型原生室内基线 |
| 3DGSWorld | 高视觉还原、粗物理代理对照 |
| ApartmentWorld | 室内导航与遮挡 |
| Town10World | 大世界视觉和持续负载压力测试 |

每个场景至少采集 60 秒稳态窗口，记录 real-time factor、physics Hz、UE FPS、
视觉同步 Hz、传感器 Hz、GPU/CPU 占用和机器人是否出现接触发散。G1 只先做
URDF/MJCF 装载和关节数量检查，不宣称完成 SONIC 集成。

## 复现清单校验

```bash
python3 scripts/validate_native_scene_inventory.py
python3 scripts/validate_native_scene_inventory.py \
  --manifest https://github.com/zsibot/matrix/releases/download/v0.1.2/manifest-0.1.2.json
python3 -m unittest tests/test_native_scene_inventory.py
```

已发现 0.1.2 的 `assets-0.1.2.tar.gz` 元数据不一致：release manifest 和 GitHub
asset digest 为
`c4af445e468bb919909176113a8b8e9b0ede5dabf80be7112a5e7e86085bb369`，但总
checksums 文件写的是
`3099ea010e400b4c16f5765fad6a465687d97e52a9ca49177800b3e67872b52b`，release
notes 又写成
`ec18164489775c9f5ac1f73da4790c8c5d18f701cddf48ec1a8e8d7b3861e8fc`。
安装时应以 manifest、GitHub digest 和实际文件三方一致为准，并把该问题视为
可复现性缺陷。
