---
name: wb-intake
description: >-
  Quy trình NHẬN & PHÂN LOẠI một phát hiện từ downstream (website dựng bằng web-builder) thành
  local hay upstream, rồi định tuyến xử lý. Dùng khi: có báo cáo "WEB-BUILDER UPSTREAM REQUIRED";
  điều tra một bug/nhu cầu có thể thuộc thư viện; quyết định fix tại project hay đẩy lên skill.
  Trigger: "intake", "phân loại finding", "local hay upstream", "upstream candidate", "skill-bug",
  "WEB-BUILDER UPSTREAM REQUIRED", "/wb-intake". KHÔNG dùng khi: đã chắc là component fix trong repo
  (đi thẳng /wb-change); hay chỉ dựng UI (skill web-builder).
---

# /wb-intake — phân loại & định tuyến finding downstream

Định tuyến đúng là thứ giúp skill **dồn chất lượng**: bug thật của thư viện chảy ngược về sửa một lần cho tất
cả; quirk riêng của project thì ở lại local. **Không bao giờ tự sửa repo khác** — finding upstream là để
**báo cáo**, không phải tự vá.

> Luật phân loại nằm ở `web-builder/references/problem-routing.md` (nạp khi cần).

## Các bước

**1 · Dựng minimal repro trên skill đã ship.** Dựng lại triệu chứng chỉ bằng `wb-*` stock + `web-builder.css`
mới nhất, **không** custom code. Đây là bước quyết định.

**2 · Phân loại.** Có thể dùng `bash scripts/classify-problem.sh <evidence.json>` cho tín hiệu rõ:
- Repro trên skill ship, không cần custom → **`skill-bug`** (upstream).
- Biến mất khi bỏ custom CSS/JS, hoặc là business-rule/content/branding riêng → **`project-local`**.
- Primitive/pattern tái dùng được mà thư viện thiếu → **`upstream-candidate`** (upstream).
- Gap tích hợp framework áp dụng rộng → **`skill-integration`** (upstream).
- Chưa đủ chứng cứ → **`needs-triage`** (điều tra thêm, đừng đoán).

**3 · Định tuyến.**
- `project-local` / `project-architecture` → sửa tại project (hoặc quay `/wb-architect` nếu là vấn đề cấu
  trúc project). Xong.
- `skill-bug` / `upstream-candidate` / `skill-integration` → phát ra khối **WEB-BUILDER UPSTREAM REQUIRED**
  (mẫu trong `problem-routing.md`): ID · Type · Evidence · Suggested change · Affected skill files · Release
  required. **Không** tự sửa upstream từ session downstream.

**4 · Khi thực thi upstream trong repo web-builder này:** nếu là component/token → chạy **`/wb-change`** (nó lo
cascade 6 nơi + gate). Nếu là kiến trúc/tooling → dùng `/wb-architect` hoặc sửa reference tương ứng. Sau khi
sửa xong và cần phát hành → `/wb-release`.

## Token discipline
Đọc rộng (tìm nơi tái dùng, đối chiếu) → **subagent**. Dùng `scripts/classify-problem.sh` cho phần
deterministic thay vì tự luận.
