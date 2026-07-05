# FoodScore — GPT Prompt & JSON Schema（Backend 对齐说明）

> Flutter 端镜像文件：`lib/prompts/food_score_prompt.dart`  
> 数据模型：`lib/models/food_score_result.dart`  
> **当前未连接 OpenAI** — 本文档仅供 FastAPI backend 集成时参考。

---

## 1. GPT 任务

根据用户输入的 **meal text** 和/或 **meal image**，生成一份餐食质量评估，输出为 **单个 JSON 对象**，可反序列化为 Flutter 的 `FoodScoreResult`。

- 仅提供 **近似、餐食级别** 的 food quality 反馈
- **不是** 医疗建议或精确营养计算
- 输出 **纯 JSON**，不要 markdown 代码块，不要额外解释文字

---

## 2. 必须返回的字段

| JSON 字段 | 类型 | 说明 |
|-----------|------|------|
| `mealName` | string | 餐食简称 |
| `overallScore` | int (1–10) | 总体食物质量分 |
| `overallLabel` | string | 与总分匹配的短标签，如 Good / Excellent |
| `summary` | string | 总体评价摘要段落 |
| `dimensions` | array[4] | 四个固定维度，见下文 |
| `tips` | array[string] | 可操作的改进建议（通常 2–5 条） |
| `positiveNotes` | array[string] | 正向观察 / 鼓励语（通常 1–4 条） |
| `disclaimer` | string | Tips 页底部免责声明 |

### `dimensions[]` 每项字段

| 字段 | 类型 | 说明 |
|------|------|------|
| `name` | string | 固定维度名（必须完全一致） |
| `description` | string | 固定维度说明（必须完全一致） |
| `score` | int (1–10) | 该维度分数 |
| `label` | string | 短标签，如 Good / Fair |
| `feedback` | string | 1–2 句维度反馈 |

---

## 3. 四个固定 Dimensions（顺序不可变）

### 1. Meal Balance
- **description:** `Protein, carbs, fats and vegetables.`
- **评分方向:** 蛋白质、碳水、健康脂肪、蔬菜是否搭配合理。10 = 搭配均衡；1 = 严重失衡。

### 2. Food Variety
- **description:** `Different food groups, colours and ingredients.`
- **评分方向:** 食物组、颜色、食材多样性。10 = 多样丰富；1 = 单一单调。

### 3. Whole Food Quality
- **description:** `Fresh, whole and minimally processed foods.`
- **评分方向:** 新鲜、完整、 minimally processed 程度。10 = 多为天然/少加工；1 = 高度超加工。

### 4. Processing & Concerns
- **description:** `Added sugar, salt, sauces or ultra-processed items.`
- **评分方向（重要）:** **分数越高 = concerns 越少。**  
  10 = 几乎无加工顾虑；1 = 大量添加糖/盐/酱/超加工食品。  
  **不要** 将此维度与其他维度反向混淆。

---

## 4. 输出格式要求

```
✅ 仅返回 JSON 对象
❌ 不要 ```json 代码块
❌ 不要前后解释文字
❌ 不要额外字段（除非 backend 层剥离后再转发给 Flutter）
```

示例见 `food_score_prompt.dart` 中的 `FoodScorePrompt.exampleJson`。

---

## 5. ResultPage 三页字段映射

Flutter `ResultPage` 使用 `PageView`，三个 Tab 与 JSON 字段对应关系：

### Page 1 — Score
| 字段 | UI 位置 |
|------|---------|
| `overallScore` | 圆形分数（OUT OF 10） |
| `overallLabel` | 分数下方标签 |
| `mealName` | 餐食名称 |
| `summary` | 名称下方摘要 |

### Page 2 — Insight
| 字段 | UI 位置 |
|------|---------|
| `mealName` | Hero 卡片 |
| `overallScore` | Hero 右侧分数 |
| `dimensions[]` | SCORE BREAKDOWN 列表 |
| `dimensions[].name` | 维度标题 |
| `dimensions[].description` | 维度固定说明 |
| `dimensions[].score` / `label` | 分数、标签、进度条 |
| `dimensions[].feedback` | 卡片底部反馈文案 |

### Page 3 — Tips
| 字段 | UI 位置 |
|------|---------|
| `positiveNotes[0]` | Hero「NEXT TIME, TRY」下方标题 |
| `positiveNotes[1..]` | WHAT THIS MEAL DOES WELL 列表 |
| `tips[]` | 白色建议卡片 |
| `disclaimer` | Remember 免责声明 |

Tab 名称、维度 emoji、区块标题等为 **固定 UI**，不在 GPT JSON 中。

---

## 6. 建议的 FastAPI 端点（尚未实现）

| 方法 | 路径 | 请求 | 响应 |
|------|------|------|------|
| POST | `/analyse-text` | `{ "meal_text": "..." }` | `FoodScoreResult` JSON |
| POST | `/analyse-image` | multipart: image + optional description | `FoodScoreResult` JSON |

Flutter 切换：`lib/config/app_config.dart` → `useMockResult = false`

---

## 7. Backend 集成检查清单

- [ ] System prompt 使用 `FoodScorePrompt.buildSystemPromptWithSchema()` 或等价内容
- [ ] GPT 响应校验：`dimensions.length == 4`，name/description 与固定值匹配
- [ ] `overallScore` 与各 dimension `score` 均为 1–10 整数
- [ ] Processing & Concerns：确认高分 = 低顾虑
- [ ] 响应体可直接被 Flutter `FoodScoreResult.fromJson()` 解析（待实现）
- [ ] 错误时返回 HTTP 4xx/5xx + 可读 message，Flutter Loading 页会显示 Retry
