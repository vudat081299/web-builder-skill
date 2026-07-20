---
name: wb-change
description: >-
  Quy trình chuẩn để THÊM/SỬA một primitive component hoặc RESTRUCTURE trong repo web-builder —
  điều phối: discover → plan → confirm → implement → đồng bộ 6 nơi (cascade) → check lỗi → verify →
  rà soát tái dùng → review code → review docs → guardrails → commit + push. Dùng khi user muốn thêm component wb-*,
  đổi token/cấu trúc, hay sửa nhiều file liên đới trong repo này. Trigger: "thêm component",
  "add primitive", "component mới", "restructure", "đổi token", "sửa wb-*", "add a component",
  "/wb-change". KHÔNG dùng khi: chỉ DÙNG thư viện để dựng UI ứng dụng (đó là skill web-builder),
  hay sửa một dòng không đụng tới component/token nào.
---

# /wb-change — thêm/sửa component & restructure cho web-builder

Repo này là **reuse-first**: một thay đổi component chạm nhiều file, lệch một nơi là SKILL/docs nói dối
AI kế tiếp. Skill này là bản điều phối của quy trình trong `CLAUDE.md` (§ *Adding or changing a component*).

> **Sản phẩm cuối cùng của repo = bộ skill `web-builder`** (SKILL.md + references + `web-builder.css` —
> file duy nhất ship). Mọi thay đổi phải để lại skill ở trạng thái **shippable, chất lượng**; vì thế
> guardrail validate **cả skill**, không chỉ docs site (xem bước 9).
**Tiết kiệm token**: đẩy việc đọc rộng cho subagent, để hook shell lo phần deterministic; model chỉ làm
phần semantic.

## Bản đồ liên đới (cascade — thuộc trước khi sửa)
Sửa một component = đồng bộ tối đa **6 nơi**:
1. `web-builder/assets/web-builder.css` — rule `.wb-*` (token, **không** hex/px thô: hairline `var(--wb-bw)`, pill `var(--wb-radius-pill)`).
2. `web-builder/assets/pages/<id>.html` — demo, **markup-only** (KHÔNG `<style>`; layout bằng `wb-cluster/stack/grid`).
3. `web-builder/assets/app.js` — `{ id, label }` vào đúng **nhóm intent** (`group`) trong **section `components`** của mảng `SECTIONS` (component mới luôn vào đây; trang nền tảng/meta thì vào `items` phẳng của section `design`/`project`). Các `group` của `components` chính là source-of-truth danh sách nhóm mà CHECK 10 gác — **đừng chép cứng ra prose** (nó trôi lệch: từng có bản 8 nhóm kèm "Biểu đồ" ma). Danh sách nhóm đầy đủ: xem `SKILL.md` "Current scope".
4. `web-builder/references/components-catalog.md` — section + 1 dòng "Quick decision guide".
5. `web-builder/SKILL.md` — thêm vào đúng nhóm scope (AI's first read).
6. Nếu liên quan: `design-principles.md` (convention mới) · `integration.md` (cần behaviour engine) · `bootstrap-comparison.md` (coverage) · `CHANGELOG.md` (part **user-visible** mới/đổi — kẻo changelog ship bị mục).
   Thêm **nguyên tắc §N mới** vào `design-principles.md` ⇒ phải render §N **đầy đủ** trên `pages/principles.html` **và** thêm §N vào index của `overview.html` (§23; CHECK 11b+11c chặn commit nếu thiếu).

## Các bước (đúng flow đã chốt)

**1 · Discover + khả thi.** Đọc `references/components-catalog.md` + `design-principles.md` trước — có thể đã
tồn tại (reuse) hoặc ghép được từ primitive sẵn có (vd list mới = `wb-list`+`wb-card`). Việc đọc rộng →
**subagent Explore** ("X đã có chưa · ghép từ gì · đụng nơi nào"), giữ context chính gọn. Cần soi CSS hiện có
→ chạy **`bash .claude/tools/wb.sh locate <class>`**: nó in sẵn lệnh `Read offset/limit` cho từng **cụm** +
**blast-radius** (5 nơi sync còn lại nhắc class đó), **không** Read full `web-builder.css` (xem *Token discipline*).

**2 · Plan + confirm.** Nêu gọn: đổi component/token nào · chạm nơi nào trong 6 · ghép từ primitive nào ·
tier màu (design-principles §1 — phân loại = xám, chỉ *status* mới có màu). **Có điểm mơ hồ → hỏi user 1–2
câu ngắn TRƯỚC khi code.** Rõ thì đi tiếp (đừng hỏi thừa).

**3 · Implement.** CSS trước (token, không magic number) — hook PostToolUse tự nhắc checklist 6 nơi ngay khi
bạn chạm `web-builder.css`. Rồi demo page → NAV → catalog → SKILL.md → (docs phụ nếu cần). Layout demo bằng
utility; chrome dùng chung đặt trong `docs.css`, **không** `<style>` trong page.
**Demo density (design-principles §22):** `demo__stage` và `demo__code` **không 1:1**. Biến thể *không phải viết
thêm* markup/class (cùng component, chỉ khác nội dung/độ dài — vd breadcrumb nhiều cấp tự wrap) → nhét specimen
vào **cùng 1 `demo__stage`** và **1 `demo__code`** (pattern in 1 lần, comment lo phần "…"); **đừng** đẻ thêm
`.demo` card / mục mới để in lại code y hệt. Chỉ tách code block/sample mới khi snippet copy **thực sự đổi**
(modifier `--striped`, cấu trúc khác, dùng khác). Litmus: *snippet có đổi không?* — không thì chung 1 card.

**4 · Check lỗi — sửa tiếp, KHÔNG xoá làm lại.** `bash .claude/hooks/validate-sync.sh` (routes==pages ·
không `<style>` lạc · `node --check app.js`). Lỗi → quay lại bước 3 sửa **đúng chỗ đó**, giữ phần đã đúng.

**5 · Verify đúng yêu cầu (xem thật).** `cd web-builder/assets && python3 serve.py` → mở `#/<id>` trong
Browser pane; kiểm cả **sáng/tối**. Xem nhiều trang → subagent, trả kết luận gọn.

**6 · Rà soát tái dùng (reuse sweep) — BẮT BUỘC.** Sau khi phần mới/đã-sửa chạy đúng: rà **toàn repo** tìm
chỗ đang làm theo cách cũ mà **nay thay được** bằng component vừa tạo, hoặc chỗ nên **áp bản cập nhật mới**
(biến thể/token/knob vừa thêm) của một component đã dùng. Quét rộng → **subagent** (trả `file:line` + đề xuất).
Áp thay thế → **verify lại** đúng chỗ vừa đổi (quay bước 5). Áp dụng cho **cả** thêm mới lẫn cập nhật component —
đây là cách repo reuse-first tự dồn chất lượng; đừng bỏ qua.

**7 · Review code.** Chạy `/code-review` trên diff.

**8 · Review docs liên đới.** Đối chiếu 6 nơi có nhất quán không (catalog ↔ SKILL.md ↔ CSS ↔ comparison).
Giao **subagent** đọc chéo, trả danh sách lệch → sửa. Và soi **docs site tự chứa (§23)**: không trang
`pages/*.html` nào được đẩy nội dung ra một `.md` thô ("đọc bản đầy đủ ở X.md") — render in-site, dùng
accordion / trang riêng và link in-site (CHECK 12 nhắc; hai bề mặt AI vs người là khác nhau — layering trong
`SKILL.md → references/*.md` thì giữ nguyên).

**9 · Guardrails (bộ tiêu chuẩn, tự chạy khi commit).** `validate-sync.sh` (cũng là PreToolUse gate) kiểm
**cả docs lẫn skill deliverable**: docs (routes==pages · page markup-only · `app.js` parse) + **skill**
(SKILL.md có frontmatter + description ≤ cap · mọi `references/*.md` tồn tại · catalog không khai class CSS
không có · `web-builder.css` cân ngoặc). Rồi soi bằng mắt: color-ladder (§1) · token-over-magic-number
(§18) · × top-right (§15) · no left-accent bar (§9) · dark = light-lift shadow (§2).

**10 · Commit + push.** Commit thẳng `main` (workflow solo, CLAUDE.md § Git). Message kết bằng:
`Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`. Rồi push.

## Token discipline (mục tiêu tối ưu)
- Đọc rộng (discover · verify nhiều trang · review docs chéo) → **subagent**, không kéo cả file vào luồng chính.
- **Không đọc full `web-builder.css`** (~2900 dòng ≈ ~40k token). Dùng **`bash .claude/tools/wb.sh locate <class>`** —
  nó tự làm 3 bước dưới và in sẵn lệnh `Read offset/limit` cho từng cụm + blast-radius, để chỉ việc copy-chạy:
  1. `grep -n 'wb-<comp>' web-builder.css` → ra *toàn bộ* dòng của component. Rule nằm **rải rác**: token trong
     `:root` · khối chính · `.dark`/`:where()` override · chỗ component khác tái dùng nó (receipt tái dùng card).
  2. Gom các dòng liền nhau thành **cụm**.
  3. `Read` từng cụm bằng `offset/limit` (+vài dòng đệm) — **không** đọc một cửa sổ cố định ±N dòng.
  grep không giới hạn độ dài nên **bất chấp component dài hay rải rác**; cửa sổ cố định thì sẽ **sót rule**.
  Ví dụ: `receipt` liền khối ~145 dòng → 1 lát ~2k token (thắng 20×); `input`/`card`/`chart` rải gần cả file →
  ~3 cụm ~300 dòng (vẫn thắng ~8×). Lát đọc lỡ sót? Không ship lỗi âm thầm — bước 4 (validate-sync) + bước 5
  (verify sáng/tối) làm demo page vỡ ngay; worst case là đọc lại.
- **Không** nhét quy trình vào `CLAUDE.md` (resident mỗi turn) — nó nằm ở skill này, nạp khi cần.
- Để **hook** lo đếm/đối chiếu deterministic (miễn phí token); model chỉ làm phần cần suy nghĩ. Nhưng
  **chỉ tự động khi tín hiệu sạch**: §18 (magic-number) và coherence "6 nơi" đã thử và **quá nhiễu** để làm
  gate (mask-alpha, hue-wheel, token trong prose…) → vẫn là eyeball của model/người (bước 8–9). Lý do + số liệu:
  README § *Deliberate trade-offs*. Đừng dựng lại gate cho chúng nếu chưa có cách tách nhiễu.
