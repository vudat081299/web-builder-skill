---
name: wb-release
description: >-
  Quy trình VALIDATE → PACKAGE → VERIFY artifact skill web-builder (web-builder.skill) và chuẩn bị
  cài đặt. Dùng khi: đóng gói/phát hành skill sau khi đã đổi source; kiểm tra artifact có bị stale;
  chuẩn bị cài vào một skills directory. Trigger: "release", "đóng gói skill", "package skill",
  "build .skill", "verify package", "install skill", "/wb-release". KHÔNG dùng khi: đang đổi component
  (đó là /wb-change) hay dựng UI (skill web-builder). KHÔNG tự commit/push/cài ra ngoài nếu chưa được
  user cho phép trong phiên.
---

# /wb-release — đóng gói & xác minh artifact skill

Toàn bộ logic deterministic ở `scripts/` (chạy ngoài Claude được). Skill này chỉ **điều phối** + nhắc ranh
giới quyền.

> Phân biệt artifact (section 14, xem `README.md`): **runtime** = `web-builder.css` (+ templates là source
> copy) · **agent skill artifact** = thứ `web-builder.skill` ship (SKILL + references + css + templates +
> pages) · **repo-only instrumentation** = docs app (`index.html`/`app.js`/`docs.css`), `.claude`, `scripts/`,
> tests · **generated** = `web-builder.skill` + manifest + checksum. Manifest quyết định file nào ship:
> `scripts/skill-manifest.txt`.

## Các bước

**1 · Một lệnh.** `bash scripts/release-skill.sh` — nó chạy tuần tự:
1. `scripts/verify.sh` — verify source (docs site + skill deliverable + kiến trúc/forward-tests).
2. `scripts/package-skill.sh` — đóng gói **deterministic** từ manifest (sorted, timestamp cố định, store);
   không kèm `.DS_Store`/temp/local state/docs app.
3. `scripts/verify-package.sh` — unpack ra temp, **parity 2 chiều** với manifest, **phát hiện stale** (nội
   dung gói phải khớp source từng byte), báo version + content-hash.

Từng bước cũng chạy riêng được nếu cần soi.

**2 · Đọc kết quả.** Ra "RELEASE CANDIDATE READY" + version + checksum = artifact tươi, đầy đủ, trung thực.
Nếu báo **STALE**/parity lỗi → `package-skill.sh` lại (đừng sửa bằng tay artifact).

**3 · Cài đặt (tuỳ chọn, cần quyền).** `bash scripts/install-skill.sh` mặc định **dry-run**: resolve target
(`--target` > `$WB_SKILL_INSTALL_DIR` > `scripts/install-config.local.sh`) và báo sẽ cài đâu, không đụng gì.
Chỉ `--apply` mới copy — đó là **hành động rõ ràng của user**. **Agent KHÔNG tự chạy `--apply`, không commit,
không push** nếu user chưa cho phép trong phiên (nó ghi ra ngoài repo).
Đích cài bị **kiểm trước khi xoá**: chỉ chấp nhận path vắng, rỗng, hoặc có `SKILL.md` (bản cài trước). Đích lạ
có nội dung → **từ chối**, phải `--force` mới ghi đè. Dry-run cũng in trạng thái đích, nên soi trước khi apply.

**4 · Version.** Repo giữ **một** chuỗi version = `--wb-version` trong CSS (protected). CHECK 15 khoá nó khớp
CHANGELOG + header CSS + SKILL.md + docs chrome. `/wb-release` không tự bump version; đổi version là việc của
`/wb-change` khi cắt release CSS.

## Token discipline
Đây là việc deterministic — để `scripts/` lo, đừng tự đọc/so file bằng tay.
