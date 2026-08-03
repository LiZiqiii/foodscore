# FoodScore — GPT Prompt & JSON Schema（Backend 对齐说明）

> Flutter 端镜像文件：`lib/prompts/food_score_prompt.dart`  
> 数据模型：`lib/models/food_score_result.dart`  
> **生产 prompt / schema 以 `backend/main.py` 为准**（`SYSTEM_PROMPT`、`RESPONSE_JSON_SCHEMA`）。

---

## 1. GPT 任务

根据用户输入的 **meal text** 和/或 **meal image**，生成一份餐食质量评估，输出为 **单个 JSON 对象**，可反序列化为 Flutter 的 `FoodScoreResult`。

- 仅提供 **近似、餐食级别** 的 food quality 反馈
- **不是** 医疗建议或精确营养计算
- 输出 **纯 JSON**，不要 markdown 代码块，不要额外解释文字
- **Score / Insight / Tips 三页内容分工明确，避免重复**

---

## 2. 必须返回的字段

| JSON 字段 | 类型 | 说明 |
|-----------|------|------|
| `mealName` | string | 餐食简称 |
| `overallScore` | int (0–100) | 总体食物质量分（四维度均值 ×10） |
| `overallLabel` | string | 与总分匹配的短标签 |
| `summary` | string | Score 页总体摘要（无建议用语） |
| `dimensions` | array[4] | 四个固定维度 |
| `insight` | object | Insight 页：`keyInsights` 数组（2–3 条） |
| `tips` | object | Tips 页：`tips` 字符串数组（1–2 条） |
| `disclaimer` | string | Tips 页底部免责声明 |

**已移除：** `whatThisMealDoesWell`、`whatCouldBeImproved`、`positiveNotes`、根级 string `tips`。

### `insight.keyInsights[]`

| 字段 | 类型 | 说明 |
|------|------|------|
| `title` | string | 综合洞察标题 |
| `description` | string | 跨维度解读，无 action 词、无直接建议 |

### `tips.tips[]`

| 元素 | 类型 | 说明 |
|------|------|------|
| 每条 | string | 针对本餐的可执行建议（1–2 条） |

### `dimensions[]` 每项字段

| 字段 | 类型 | 说明 |
|------|------|------|
| `name` | string | 固定维度名（必须完全一致） |
| `description` | string | 固定维度说明（必须完全一致） |
| `score` | int (0–10) | 该维度分数 |
| `label` | string | 短标签 |
| `feedback` | string | **一条** factual 评分依据（无建议 / 无 try-add-consider 等） |

---

## 3. 四个固定 Dimensions（顺序不可变）

与 `backend/main.py` 中 `DIMENSION_DEFINITIONS` 一致。

### 4. Processing & Concerns
**分数越高 = concerns 越少。**

---

## 5. ResultPage 三页字段映射

### Page 1 — Score
| 字段 | UI 位置 |
|------|---------|
| `overallScore` / `overallLabel` | Hero |
| `mealName` / `summary` | 餐食信息 |
| `dimensions[].score` | 进度条 |
| `dimensions[].feedback` | 维度下 factual 说明 |

### Page 2 — Insight
| 字段 | UI 位置 |
|------|---------|
| `mealName` / `overallScore` | Hero 卡片 |
| `insight.keyInsights[]` | **KEY INSIGHTS** 白色卡片 |

### Page 3 — Tips
| 字段 | UI 位置 |
|------|---------|
| `tips.tips[]` | 1–2 条 lightbulb 建议卡片 |
| `disclaimer` | Remember 免责声明 |

Tab 名称、维度 emoji、区块标题等为 **固定 UI**，不在 GPT JSON 中。

示例 JSON 见 `food_score_prompt.dart` → `FoodScorePrompt.exampleJson`。
