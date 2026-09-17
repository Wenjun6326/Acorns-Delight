# 参与开发 / Contributing

## 分支策略

| 分支 | 定位 | 往里提交什么 |
| --- | --- | --- |
| **`main`** | **主要开发线** | 新功能、新玩法。下一个大版本（如 `1.2.0`）的工作都在这里。 |
| **`release/1.1`** | **稳定维护线** | 只放 `1.1.x` 的 bug 修复与优化，让 `1.1.1` 这条线持续变好；**不放新玩法**。 |

`release/1.1` 是**发行线**，不是临时分支，不要删。它的意义是：`1.1.1` 是第一个自己开发的
农夫乐事附属版本，作为一个纪念点冻结下来，之后的打磨（数值微调、贴图、兼容性修复）都
提交到这条线上，用 `1.1.1` → `1.1.2` → `1.1.3` 的形式发布；而全新的内容推到更后面的版本，
走 `main`。

**提交到哪里？**

* 修 bug、调数值、改贴图、适配新版本 → `release/1.1`，然后发 `1.1.x`
* 加新物品、新机制、新配方 → `main`，然后发 `1.2.0` 及以后

若某个修复对两边都必要（例如安全或崩溃问题），在 `release/1.1` 修完后用
`git cherry-pick` 带到 `main`。

## 版本规范

版本号写在 `gradle.properties` 的 `version` 里，并**原样作为 Git Tag 使用**（Tag 名 == 版本号，例如 `1.1.0`）。

采用三段式 `X.Y.Z`：

| 版本 | 含义 | 例子 |
| --- | --- | --- |
| **X.Y.0** | **大改动**：加入全新机制或新玩法 | 新增「烤橡果」「橡果派」、加入烹饪锅配方、新的生物群系互动 |
| **X.Y.Z** | **小改动**：仅修复兼容性或优化问题 | 放宽 Loader 版本要求、适配 Minecraft 26.2、修复模组冲突、性能优化 |

* 两者都是「**可玩版本**」，都必须打 Tag。
* 开发过程中的中间提交**不打 Tag**。
* Tag 一旦推送就不要移动或删除——它是回滚和对比的依据。
* 小改动**不改变** `X.Y` 前缀：`1.1.0` 之后的小改动依次是 `1.1.1`、`1.1.2`；只有当出现新玩法时才升到 `1.2.0`。

### Fabric Loader 兼容性约定

`gradle.properties` 里有两个 Loader 相关字段，含义不同，别混淆：

| 字段 | 作用 |
| --- | --- |
| `loader_version` | **开发环境**实际使用的 Loader。刻意固定在**支持的最低版本**（当前 `0.18.4`），这样一旦代码误用了新版 Loader 才有的行为，会在本地 GameTest 里直接暴露，而不是等玩家崩溃。 |
| `min_loader_version` | 写进 `fabric.mod.json` 的 `depends.fabricloader`，即**玩家可用的最低 Loader**。 |

**下限由 Fabric API 决定**，不能随便往下降：当前 Fabric API `0.145.1+26.1` 自声明 `fabricloader >=0.18.4`，
而 26.1 可用的最老 Loader 也正是 `0.18.4`。升级 Fabric API 时记得重新核对这两个值，
核对方法：读 `fabric-api-<版本>.jar` 内 `fabric.mod.json` 的 `depends.fabricloader`。

## 发布流程

先确认你要发的是哪条线，然后**在对应分支上**操作。

### 修 bug / 优化 → 发布 `1.1.x`（在 `release/1.1` 上）

```bash
git switch release/1.1

# 1. 改 gradle.properties 里的 version（1.1.1 -> 1.1.2）
# 2. 更新 CHANGELOG.md（仓库内的中文正式历史）
# 3. 新建 release-notes/<version>.md（英文，GitHub Release 的正文）
# 4. 验证，必须全绿（否则不要发布）
./gradlew runGameTest build

# 5. 提交并推送
git add -A
git commit -m "Release 1.1.2: 修正 xxx"
git push origin release/1.1

# 6. 打 Tag（Tag 名必须和 version 完全一致）并推送
git tag 1.1.2
git push origin 1.1.2

# 7. 发布 Release 并自动上传 jar（必须做，玩家不会自己编译）
powershell -ExecutionPolicy Bypass -File .\scripts\publish-release.ps1
```

### 新功能 → 发布 `1.2.0` 及以后（在 `main` 上）

把上面第 5 步的 `release/1.1` 换成 `main` 即可，其余相同。

> **约定：每发布一个版本，都要在 GitHub 上建对应的 Release，并附上构建好的 jar。**
> 只推 tag 不算发布完成 —— 玩家在 Releases 页面拿不到可下载的文件。

### Release 说明为什么用英文

GitHub 的 Release 正文面向国际玩家，因此放在 `release-notes/<version>.md` 且用**英文**撰写；
`CHANGELOG.md` 保留中文，作为仓库内的正式历史。`publish-release.ps1` 优先读取
`release-notes/<version>.md`，找不到时才回退到从 `CHANGELOG.md` 截取对应小节。

### 发布前检查清单

- [ ] `gradle.properties` 的 `version` 已更新
- [ ] **在正确的分支上**：`1.1.x` 在 `release/1.1`，新功能在 `main`（`git branch --show-current` 确认）
- [ ] `CHANGELOG.md` 已更新（中文）
- [ ] `release-notes/<version>.md` 已新建（英文）
- [ ] `./gradlew runGameTest` 输出 `All 6 required tests passed :)`
- [ ] `./gradlew build` 成功，`build/libs/acorns-delight-<version>.jar` 存在
- [ ] 若升级了 Minecraft 版本，`minecraft_version`、`fabric_api_version`、`jei_version` 三者同步更新
      （JEI 每个 Minecraft 版本一个 artifact，换 MC 版本必须换 JEI 版本）
- [ ] 若升级了 Fabric API，重新核对 `min_loader_version`
- [ ] Tag 名与 `version` 一致，且已推送（`git push origin <tag>`）
- [ ] 运行 `scripts/publish-release.ps1`，确认 GitHub 上出现了 Release **且带有 jar 附件**
- [ ] 被取代且有已知问题的旧版本，用 `-Prerelease` 发布，避免它占据 "Latest" 并误导玩家

### 编码注意事项（踩过的坑）

Windows PowerShell 5.1 在中文系统上默认按 **GBK/936** 处理文本，已两次造成实际事故：

1. **写文件**：`Get-Content -Raw` 读无 BOM 的 UTF-8 文件会得到乱码，写回就把文件**永久损坏**
   （曾导致 README 在 GitHub 上显示为乱码）。→ 始终用
   `[System.IO.File]::ReadAllText/WriteAllText(path, ..., UTF8Encoding($false))`。
2. **发 HTTP 请求**：`ConvertTo-Json` 把非 ASCII 转成 `\uXXXX`，而 `Invoke-RestMethod`
   用字符串 body 时按 ISO-8859-1 发送，`\u` 被压成 `?`
   （曾导致 Release 说明里 563 个中文变成 229 个问号）。→ 显式
   `[System.Text.Encoding]::UTF8.GetBytes($json)` + `charset=utf-8`。

因此 `scripts/*.ps1` 一律保存为**纯 ASCII**，避免依赖读取编码。

## 开发环境

| 组件 | 版本 |
| --- | --- |
| JDK | **25**（必须，26.1 要求） |
| Gradle | 9.5.1（wrapper 自带，无需安装） |
| Fabric Loom | 1.17.20 |
| Fabric Loader（开发用） | **0.18.4**（刻意用最低支持版本，见上文） |
| Fabric Loader（玩家最低） | 0.18.4 |
| Fabric Loader（当前稳定） | 0.19.5 |

常用命令：

```bash
./gradlew build          # 构建
./gradlew runGameTest    # 游戏内测试（CI 级别的验证）
./gradlew runServer      # 起一个开发用服务端
./gradlew runClient      # 起一个开发用客户端
```

> Loom 1.17 的 GameTest 任务名是 `runGameTest`（大写 T）。

## 26.1 特有的坑

26.1 是 Minecraft 首个**不混淆**版本，大量 API 与 1.21.x 不同。写代码前请注意：

* **没有 `mappings` 依赖行**；`modImplementation` / `remapJar` 改为 `implementation` / `jar`；插件 id 是
  `net.fabricmc.fabric-loom`（不再是 `fabric-loom`）。
* `ResourceLocation` → **`Identifier`**。
* `ItemGroupEvents` → **`CreativeModeTabEvents`**（包 `net.fabricmc.fabric.api.creativetab.v1`）；
  `FabricItemGroupEntries` → `FabricCreativeModeTabOutput`；`modifyEntriesEvent` → `modifyOutputEvent`。
* `CreativeModeTabs` 里的物品栏常量已经变成 **private**，不能再 `modifyOutputEvent(CreativeModeTabs.INGREDIENTS)`；
  请注册自己的物品栏。
* 注册物品必须调用 **`Item.Properties#setId(ResourceKey<Item>)`**，否则崩。
* 战利品表是**可重载的数据包注册表**，要从 `server.reloadableRegistries().getLootTable(key)` 取，
  而不是 `registryAccess().lookupOrThrow(...)`；`Registry.getOrThrow` 已改名 **`getValueOrThrow`**。
* 物品需要**两个** JSON：`assets/<ns>/items/<name>.json`（client item，必需，缺了会显示紫黑方块）
  和 `assets/<ns>/models/item/<name>.json`。合成配方目录是单数 `data/<ns>/recipe/`。
* **单个条目的战利品池必定掉落**——要做概率掉落必须用权重互补的条目
  （本项目用 13 : 87，空条目由 `EmptyLootItem` 提供）。这个坑曾经让掉落率变成 100%。

## 兼容性依赖说明

JEI、REI、Farmer's Delight 全部是 **compileOnly**（可选）依赖，不会打进成品 jar。

* `mezz.jei:jei-<mc>-fabric` 从 [BlameJared](https://maven.blamejared.com) 解析。
  注意其 `-fabric-api` artifact 在 26.1 上只是一个**空壳**，真正带 `mezz.jei.api` 类的是完整 jar。
* REI 在 26.1 **没有发布到任何 Maven 仓库**，因此 `libs/RoughlyEnoughItems-26.1.819.jar` 是随仓库
  携带的编译用 jar，来源与授权见 [`libs/README.md`](libs/README.md)。
* Farmer's Delight 走 Modrinth maven（`api.modrinth.com/maven`）。

运行时通过 `fabric.mod.json` 里的入口点加载（`jei_mod_plugin`、`rei_client`），
玩家没装对应模组时这些入口点不会被执行。
