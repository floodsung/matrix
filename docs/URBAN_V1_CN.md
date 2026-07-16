# Matrix 都市场景 V1

## 定位

`urban-v1` 使用 Matrix 0.1.2 原生 `Town10World`（场景 2）作为第一版城市基底。
它有完整的道路、建筑、路灯、绿化、车辆和行人视觉，MuJoCo 侧有 869 个原生
静态环境几何体。它比 ApartmentWorld 或自制厂房更接近真实都市，但还不是经过
2080 科幻美术改造的 Overworld。

固定契约在 `research/urban_v1/scene.json`。原生人物和车辆目前只是 UE 展示资产，
没有对应的动态 MuJoCo body，不能宣称可物理交互或可作为动态障碍训练真值。

## G1 材质

G1 的 canonical URDF 已包含与 AUE G1 相同的基础配色：主体 `white=0.7 0.7 0.7 1`，
关节、骨盆、头部等 `dark=0.2 0.2 0.2 1`。此前通用导入流程把视觉网格统一指向
`default_material`，所以 Matrix 中接近纯灰。

流水线 V14 会把 URDF 的具名或内联颜色转换为独立 MJCF material，并同时保留
geom RGBA 作为兼容回退。旧 V13 缓存会自动重建，不需要手工删除缓存。材质只改变
视觉，不改变 collision、质量、惯量、关节或 SONIC 控制。

TRNA 主链路验收结果位于
`research/urban_v1/results/trna_urban_material_20260716.json`：G1 的 36 个来源
visual 覆盖到 41 个实际视觉 geom，白色 32 个、深色 9 个、未匹配 0 个；Town10
录制为 1920x1080、30 FPS、10 秒，SONIC 物理约 200 Hz、RTF 约 1.0，未跌倒或
触发稳定性重置。

## 启动

```bash
cd /home/trna/matrix-eval
bash scripts/run_matrix_sonic_urban_v1.sh \
  --urdf /home/trna/matrix-sonic-assets/g1_29dof/g1_29dof.urdf \
  --control-source planner \
  --walk-after 10 \
  --vx 0.25
```

录制仍走同一条主链路：

```bash
bash scripts/record_matrix_sonic_video.sh \
  --output outputs/videos/matrix_sonic_urban_v1.mp4 \
  --duration 15 --fps 30 \
  -- \
  bash scripts/run_matrix_sonic_urban_v1.sh \
    --urdf /home/trna/matrix-sonic-assets/g1_29dof/g1_29dof.urdf \
    --control-source planner --walk-after 10 --vx 0.25 --max-seconds 75
```

## 2080 层的边界

当前发布物只有 UE 5.5.4 cooked map，没有可编辑源工程。V1 保留真实原生城市，不用
纯色方块伪装科幻资产。拿到匹配的 UE 源地图后，再做夜间照明、远程机器人基础设施、
零子战争痕迹、星舰通信设施和可交互任务物件，并为新增动态对象补 MuJoCo/SONIC
物理与数据标注。
