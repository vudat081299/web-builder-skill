---
name: wb-architect
description: >-
  Quy trình chọn/synthesize KIẾN TRÚC project cho một website dựng bằng web-builder — chạy complexity
  gate (Level 0/1/2), rồi hoặc giữ one-file fast path, hoặc synthesize cây tối thiểu vừa đủ từ ràng
  buộc thật. Dùng khi: bootstrap website/trang mới; thiết kế hoặc refactor architecture; thêm screen
  flow/khối tính năng lớn; refactor monolith/large site; migrate file khổng lồ. Trigger: "dựng
  website mới", "bootstrap", "chọn kiến trúc", "architecture", "restructure", "refactor monolith",
  "migrate", "/wb-architect". KHÔNG dùng khi: chỉ THÊM/SỬA component wb-* trong repo (đó là /wb-change);
  chỉ DÙNG thư viện ráp UI mà không đụng cấu trúc (skill web-builder); hay việc routine (sửa content,
  data, bug nhỏ local) — những việc đó KHÔNG cần Web Builder.
---

# /wb-architect — chọn & synthesize kiến trúc project

Web Builder làm **UI đẹp** (skill `web-builder`); skill này lo **cách tổ chức project** để agent bảo trì tiếp
được. Kiến trúc là **năng lực thích ứng, KHÔNG phải nghi thức bắt buộc**. Đa số build là nhỏ → **mặc định one
file**. Đừng dựng folder/`.agent/` cho trang không cần.

> Nguồn tri thức nằm trong references (nạp khi cần), không chép vào đây:
> `web-builder/references/project-architecture.md` (gate + synthesis + patterns + decomposition + evolution),
> `site-profiles.md` / `learning-sites.md` (prior theo loại site), `large-static-sites.md` (file lớn/monolith),
> `project-protocol.md` (contract để lại), `problem-routing.md`, `verification.md`.

## Các bước

**1 · Complexity gate TRƯỚC.** Chạy gate trong `project-architecture.md` (§ *The complexity gate*). Cần đọc
nhanh một mô tả project → có thể dùng `bash scripts/classify-project.sh <mô-tả.json>` cho tín hiệu rõ ràng
(L0/L1/L2 + gợi ý migrate). **Nếu Level 0 → DỪNG:** tạo/giữ một `index.html` đẹp bằng `wb-*`, responsive,
accessible, một check render tối thiểu. Không `.agent/`, không docs kiến trúc, không folder "để dành".

**2 · Đọc bối cảnh (nếu > Level 0).** Prompt + repo hiện có + local `AGENTS.md`/convention framework. Project
đã tồn tại → **reuse giải pháp local**, đừng restructure chỉ để giống một profile.

**3 · Synthesize (Level 1/2).** Theo `project-architecture.md` (§ *Synthesis workflow*): liệt kê
responsibilities + units-of-change → tìm source-of-truth → vẽ data flow → giữ convention framework → chọn
patterns → tham chiếu profile gần nhất (không bị trói) → ra **cây tối thiểu**. Đọc rộng repo → **subagent**.

**4 · Chọn mức nhỏ nhất giải quyết được.** Một tín hiệu ≠ maximal. Level 1 = cây nhỏ + một `AGENTS.md` ngắn.
Level 2 = thêm `.agent/`, `docs/architecture`, ADR — **chỉ khi thật cần**, không theo checklist.

**5 · Để lại contract (Level 1/2).** Viết `AGENTS.md` theo `project-protocol.md`: purpose · nơi sửa · commands
+ verify · reuse policy · **routine không cần Web Builder / khi nào gọi lại**. Ghi decision/learning/handoff
**chỉ khi có nhu cầu thật** (durable decision / root-cause tái dùng / work nhiều session).

**6 · File decomposition = chẩn đoán, không phải luật.** Tách theo *responsibility/unit-of-change*, không theo
số dòng. File cohesive 10.000 dòng có thể ổn; monolith → migrate **tăng dần** (`large-static-sites.md`),
không big-bang.

**7 · Verify.** Theo `verification.md` (tier hợp với thay đổi). UI luôn chạy `page-review.md`.

## Token discipline
Đọc rộng (repo, nhiều file) → **subagent**, trả kết luận gọn. Nạp đúng một reference cần, không kéo cả bộ.
Logic deterministic (gate, classify) đã ở `scripts/` — gọi, đừng suy luận lại bằng tay.
