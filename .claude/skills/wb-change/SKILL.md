---
name: wb-change
description: >-
  Quy trình chuẩn để THÊM/SỬA một primitive component hoặc RESTRUCTURE trong repo web-builder —
  điều phối: discover → plan → confirm → implement → đồng bộ 6 nơi (cascade) → check lỗi → verify →
  review code → review docs → guardrails → commit + push. Dùng khi user muốn thêm component wb-*,
  đổi token/cấu trúc, hay sửa nhiều file liên đới trong repo này. Trigger: "thêm component",
  "add primitive", "component mới", "restructure", "đổi token", "sửa wb-*", "add a component",
  "/wb-change". KHÔNG dùng khi: chỉ DÙNG thư viện để dựng UI ứng dụng (đó là skill web-builder),
  hay sửa một dòng không đụng tới component/token nào.
---

# /wb-change — thêm/sửa component & restructure cho web-builder

Repo này là **reuse-first**: một thay đổi component chạm nhiều file, lệch một nơi là SKILL/docs nói dối
AI kế tiếp. Skill này là bản điều phối của quy trình trong `CLAUDE.md` (§ *Adding or changing a component*).
**Tiết kiệm token**: đẩy việc đọc rộng cho subagent, để hook shell lo phần deterministic; model chỉ làm
phần semantic.

## Bản đồ liên đới (cascade — thuộc trước khi sửa)
Sửa một component = đồng bộ tối đa **6 nơi**:
1. `web-builder/assets/web-builder.css` — rule `.wb-*` (token, **không** hex/px thô: hairline `var(--wb-bw)`, pill `var(--wb-radius-pill)`).
2. `web-builder/assets/pages/<id>.html` — demo, **markup-only** (KHÔNG `<style>`; layout bằng `wb-cluster/stack/grid`).
3. `web-builder/assets/app.js` — `{ id, label }` vào đúng nhóm `NAV` (Nền tảng · Hành động · Nhập liệu · Hiển thị dữ liệu · Phản hồi · Điều hướng · Biểu đồ · Cấu trúc).
4. `web-builder/references/components-catalog.md` — section + 1 dòng "Quick decision guide".
5. `web-builder/SKILL.md` — thêm vào đúng nhóm scope (AI's first read).
6. Nếu liên quan: `design-principles.md` (convention mới) · `integration.md` (cần behaviour engine) · `bootstrap-comparison.md` (coverage).

## Các bước (đúng flow đã chốt)

**1 · Discover + khả thi.** Đọc `references/components-catalog.md` + `design-principles.md` trước — có thể đã
tồn tại (reuse) hoặc ghép được từ primitive sẵn có (vd list mới = `wb-list`+`wb-card`). Việc đọc rộng →
**subagent Explore** ("X đã có chưa · ghép từ gì · đụng nơi nào"), giữ context chính gọn.

**2 · Plan + confirm.** Nêu gọn: đổi component/token nào · chạm nơi nào trong 6 · ghép từ primitive nào ·
tier màu (design-principles §1 — phân loại = xám, chỉ *status* mới có màu). **Có điểm mơ hồ → hỏi user 1–2
câu ngắn TRƯỚC khi code.** Rõ thì đi tiếp (đừng hỏi thừa).

**3 · Implement.** CSS trước (token, không magic number) — hook PostToolUse tự nhắc checklist 6 nơi ngay khi
bạn chạm `web-builder.css`. Rồi demo page → NAV → catalog → SKILL.md → (docs phụ nếu cần). Layout demo bằng
utility; chrome dùng chung đặt trong `docs.css`, **không** `<style>` trong page.

**4 · Check lỗi — sửa tiếp, KHÔNG xoá làm lại.** `bash .claude/hooks/validate-sync.sh` (routes==pages ·
không `<style>` lạc · `node --check app.js`). Lỗi → quay lại bước 3 sửa **đúng chỗ đó**, giữ phần đã đúng.

**5 · Verify đúng yêu cầu (xem thật).** `cd web-builder/assets && python3 serve.py` → mở `#/<id>` trong
Browser pane; kiểm cả **sáng/tối**. Xem nhiều trang → subagent, trả kết luận gọn.

**6 · Review code.** Chạy `/code-review` trên diff.

**7 · Review docs liên đới.** Đối chiếu 6 nơi có nhất quán không (catalog ↔ SKILL.md ↔ CSS ↔ comparison).
Giao **subagent** đọc chéo, trả danh sách lệch → sửa.

**8 · Guardrails (bộ tiêu chuẩn, tự chạy khi commit).** `validate-sync.sh` cũng là PreToolUse gate chặn
commit nếu invariant vỡ. Soi lại bằng mắt: color-ladder (§1) · token-over-magic-number (§18) · × top-right
(§15) · no left-accent bar (§9) · dark = light-lift shadow (§2).

**9 · Commit + push.** Commit thẳng `main` (workflow solo, CLAUDE.md § Git). Message kết bằng:
`Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`. Rồi push.

## Token discipline (mục tiêu tối ưu)
- Đọc rộng (discover · verify nhiều trang · review docs chéo) → **subagent**, không kéo cả file vào luồng chính.
- **Không** nhét quy trình vào `CLAUDE.md` (resident mỗi turn) — nó nằm ở skill này, nạp khi cần.
- Để **hook** lo đếm/đối chiếu deterministic (miễn phí token); model chỉ làm phần cần suy nghĩ.
