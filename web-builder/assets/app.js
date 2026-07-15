/* =============================================================================
   Web Builder docs — shared shell (defined ONCE, reused by every page)
   -----------------------------------------------------------------------------
   • Renders the tree sidebar from NAV (group heading = primary line, items dimmer).
   • Hash router: #/<id> loads pages/<id>.html into the main column, so each
     group shows in isolation (pick "Tables" → only tables render).
   • Theme toggle, code-copy, token swatches, sticky-table fill, dual light/dark
     preview, and light interactive helpers (dropdown / modal / toast / tabs).
   Content files in pages/ stay tiny: markup only, no shell, no script.
   Serve the folder (fetch needs http) — e.g. `python3 -m http.server`.
   ========================================================================== */

/* ---- Navigation model — the single source of truth for the sidebar tree --- */
const NAV = [
  { group: "Nền tảng", items: [
    { id: "overview",   label: "Tổng quan" },
    { id: "color",      label: "Triết lý màu" },
    { id: "tokens",     label: "Design tokens" },
    { id: "typography", label: "Typography" },
    { id: "fonts",      label: "Fonts" },
    { id: "border",     label: "Border & bo góc" },
    { id: "config",     label: "Config / Tweak" },
  ]},
  { group: "Hành động", items: [
    { id: "buttons",  label: "Buttons" },
    { id: "dropdown", label: "Dropdown / Menu" },
  ]},
  { group: "Nhập liệu", items: [
    { id: "input",    label: "Text input" },
    { id: "select",   label: "Select" },
    { id: "textarea", label: "Textarea" },
    { id: "choice",   label: "Checkbox & Radio" },
    { id: "switch",   label: "Switch" },
    { id: "range",    label: "Range / Slider" },
    { id: "file",     label: "File / Upload" },
  ]},
  { group: "Hiển thị dữ liệu", items: [
    { id: "card",     label: "Card" },
    { id: "receipt",  label: "Hoá đơn (receipt)" },
    { id: "tables",   label: "Tables" },
    { id: "list",     label: "List group" },
    { id: "stats",    label: "Stat / KPI cards" },
    { id: "capsules", label: "Capsules / Badges" },
    { id: "tags",     label: "Tags (#)" },
    { id: "avatar",   label: "Avatar" },
  ]},
  { group: "Phản hồi", items: [
    { id: "alert",    label: "Alert / Banner" },
    { id: "toast",    label: "Toast" },
    { id: "modal",    label: "Modal / Dialog" },
    { id: "drawer",   label: "Drawer / Offcanvas" },
    { id: "progress", label: "Progress" },
    { id: "skeleton", label: "Skeleton" },
    { id: "empty",    label: "Empty state" },
    { id: "tooltip",  label: "Tooltip" },
  ]},
  { group: "Điều hướng", items: [
    { id: "navbar",     label: "Navbar & menu" },
    { id: "sidenav",    label: "Sidebar (side-nav)" },
    { id: "tabs",       label: "Tabs" },
    { id: "breadcrumb", label: "Breadcrumb" },
    { id: "pagination", label: "Pagination" },
    { id: "accordion",  label: "Accordion" },
    { id: "divider",    label: "Divider" },
  ]},
  { group: "Biểu đồ", items: [
    { id: "charts", label: "Charts" },
  ]},
  { group: "Cấu trúc", items: [
    { id: "tree",     label: "Tree danh mục" },
    { id: "sortable", label: "List / Grid kéo–thả" },
    { id: "layout",   label: "Grid / Layout" },
  ]},
];

const ROUTES = {};
NAV.forEach((g) => g.items.forEach((it) => (ROUTES[it.id] = it)));
const DEFAULT_ROUTE = "overview";

/* ---- Sidebar tree — heading + dimmer items. The heading is a button that
   collapses its group; the caret sits on the RIGHT (no leading triangle). ---- */
function renderNav() {
  const nav = document.getElementById("nav");
  nav.innerHTML = NAV.map((g) => `
    <div class="doc-tree__group">
      <button class="doc-tree__head" data-group-toggle aria-expanded="true">
        <span>${g.group}</span><span class="doc-tree__caret" aria-hidden="true"></span>
      </button>
      <div class="doc-tree__items">
        ${g.items.map((it) => it.coming
          ? `<span class="doc-tree__link is-coming">${it.label}<span class="doc-tree__badge">soon</span></span>`
          : `<a class="doc-tree__link" href="#/${it.id}" data-id="${it.id}">${it.label}</a>`
        ).join("")}
      </div>
    </div>`).join("");
}

/* ---- Router --------------------------------------------------------------- */
async function loadRoute() {
  const id = location.hash.replace(/^#\/?/, "") || DEFAULT_ROUTE;
  const route = ROUTES[id];
  const view = document.getElementById("view");

  if (!route || route.coming) { location.hash = "#/" + DEFAULT_ROUTE; return; }

  document.querySelectorAll(".doc-tree__link").forEach((a) =>
    a.classList.toggle("is-active", a.dataset.id === id));
  document.title = route.label + " · Web Builder";

  try {
    const res = await fetch("pages/" + id + ".html", { cache: "no-store" });
    if (!res.ok) throw new Error(res.status);
    view.innerHTML = await res.text();
  } catch (err) {
    view.innerHTML =
      '<div class="doc-coming"><h3>Không tải được trang</h3>' +
      "<p>Docs cần chạy qua HTTP server (fetch không hoạt động với <code>file://</code>).<br>" +
      "Chạy: <code>cd web-builder/assets &amp;&amp; python3 -m http.server 8777</code> rồi mở " +
      "<code>http://localhost:8777</code>.</p></div>";
    return;
  }
  window.scrollTo(0, 0);
  initPage(view);
}

/* ---- Per-page init — generic, driven by data-attributes ------------------- */
function initPage(root) {
  root.querySelectorAll("[data-swatches]").forEach(renderSwatches);
  root.querySelectorAll("[data-sticky-fill]").forEach(fillSticky);
  root.querySelectorAll("[data-dual]").forEach(renderDual);
  root.querySelectorAll("[data-tree]").forEach(initTree);
  root.querySelectorAll("[data-sortable]").forEach(initSortable);
  root.querySelectorAll("[data-sortable-rows]").forEach(initSortableTable);
}

/* ---- Sortable: flat drag-to-reorder for a list OR grid, with a dashed slot -
   The placeholder (.wb-sortable__ph) shows the empty target while dragging.
   In the app use dnd-kit; keep these classes for the look. --------------- */
function initSortable(list) {
  let dragged = null;
  const grid = list.classList.contains("wb-sortable--grid");
  const ph = document.createElement("div");
  ph.className = "wb-sortable__ph";

  list.addEventListener("dragstart", (e) => {
    const item = e.target.closest(".wb-sortable__item");
    if (!item || !list.contains(item)) return;
    dragged = item;
    e.dataTransfer.effectAllowed = "move";
    try { e.dataTransfer.setData("text/plain", "item"); } catch (_) {}
    ph.style.height = item.offsetHeight + "px";
    ph.style.width = grid ? item.offsetWidth + "px" : "";
    setTimeout(() => item.classList.add("is-dragging"), 0);
  });

  list.addEventListener("dragover", (e) => {
    if (!dragged) return;
    e.preventDefault();
    const items = [...list.querySelectorAll(".wb-sortable__item:not(.is-dragging)")];
    let ref = null;
    if (!grid) {
      for (const el of items) {
        const b = el.getBoundingClientRect();
        if (e.clientY < b.top + b.height / 2) { ref = el; break; }
      }
    } else {
      let best = null, bestD = Infinity, after = false;
      for (const el of items) {
        const b = el.getBoundingClientRect();
        const cx = b.left + b.width / 2, cy = b.top + b.height / 2;
        const d = Math.hypot(e.clientX - cx, e.clientY - cy);
        if (d < bestD) {
          bestD = d; best = el;
          const sameRow = Math.abs(e.clientY - cy) < b.height * 0.6;
          after = sameRow ? e.clientX > cx : e.clientY > cy;
        }
      }
      if (best) ref = items[items.indexOf(best) + (after ? 1 : 0)] || null;
    }
    if (ref) list.insertBefore(ph, ref); else list.appendChild(ph);
  });

  list.addEventListener("drop", (e) => {
    if (!dragged) return;
    e.preventDefault();
    if (ph.parentNode) ph.parentNode.insertBefore(dragged, ph);
    cleanup();
  });
  list.addEventListener("dragend", cleanup);

  function cleanup() {
    if (dragged) dragged.classList.remove("is-dragging");
    if (ph.parentNode) ph.parentNode.removeChild(ph);
    dragged = null;
  }
}

/* ---- Sortable TABLE rows: drag whole <tr>s to reorder, dashed row target ---
   Put data-sortable-rows on the <tbody>; make each <tr> draggable. App → dnd-kit. */
function initSortableTable(tbody) {
  let dragged = null;
  const ph = document.createElement("tr");
  ph.className = "wb-row-ph";
  const cols = () => (tbody.querySelector("tr") ? tbody.querySelector("tr").children.length : 1);
  const sizePh = () => (ph.innerHTML = '<td colspan="' + cols() + '"><div class="wb-row-ph__inner"></div></td>');

  tbody.addEventListener("dragstart", (e) => {
    const tr = e.target.closest("tr");
    if (!tr || tr.classList.contains("wb-row-ph") || !tbody.contains(tr)) return;
    dragged = tr;
    e.dataTransfer.effectAllowed = "move";
    try { e.dataTransfer.setData("text/plain", "row"); } catch (_) {}
    sizePh();
    setTimeout(() => tr.classList.add("is-dragging"), 0);
  });
  tbody.addEventListener("dragover", (e) => {
    if (!dragged) return;
    e.preventDefault();
    const rows = [...tbody.querySelectorAll("tr:not(.is-dragging):not(.wb-row-ph)")];
    let ref = null;
    for (const el of rows) {
      const b = el.getBoundingClientRect();
      if (e.clientY < b.top + b.height / 2) { ref = el; break; }
    }
    if (ref) tbody.insertBefore(ph, ref); else tbody.appendChild(ph);
  });
  tbody.addEventListener("drop", (e) => {
    if (!dragged) return;
    e.preventDefault();
    if (ph.parentNode) ph.parentNode.insertBefore(dragged, ph);
    cleanup();
  });
  tbody.addEventListener("dragend", cleanup);
  function cleanup() {
    if (dragged) dragged.classList.remove("is-dragging");
    if (ph.parentNode) ph.parentNode.removeChild(ph);
    dragged = null;
  }
}

/* ---- Tree: expand/collapse + drag to reorder & reparent (unlimited depth) - */
function initTree(tree) {
  let dragged = null;

  tree.addEventListener("dragstart", (e) => {
    const row = e.target.closest(".wb-tree__row");
    if (!row) return;
    dragged = row.closest(".wb-tree__node");
    dragged.classList.add("is-dragging");
    e.dataTransfer.effectAllowed = "move";
    try { e.dataTransfer.setData("text/plain", "node"); } catch (_) {}
  });

  tree.addEventListener("dragover", (e) => {
    if (!dragged) return;
    const row = e.target.closest(".wb-tree__row");
    if (!row) return;
    const node = row.closest(".wb-tree__node");
    if (node === dragged || dragged.contains(node)) return; // never into self/descendant
    e.preventDefault();
    clearDropMarks(tree);
    const r = row.getBoundingClientRect();
    const y = e.clientY - r.top;
    const zone = y < r.height * 0.3 ? "before" : y > r.height * 0.7 ? "after" : "inside";
    row.classList.add("is-drop-" + zone);
    row.dataset.dropZone = zone;
  });

  tree.addEventListener("drop", (e) => {
    if (!dragged) return;
    const row = e.target.closest(".wb-tree__row");
    if (!row) { cleanup(); return; }
    e.preventDefault();
    const node = row.closest(".wb-tree__node");
    const zone = row.dataset.dropZone || "after";
    if (node !== dragged && !dragged.contains(node)) {
      if (zone === "inside") {
        let ul = node.querySelector(":scope > .wb-tree__children");
        if (!ul) { ul = document.createElement("ul"); ul.className = "wb-tree__children"; node.appendChild(ul); }
        ul.appendChild(dragged);
        node.classList.remove("is-collapsed");
      } else if (zone === "before") {
        node.parentNode.insertBefore(dragged, node);
      } else {
        node.parentNode.insertBefore(dragged, node.nextSibling);
      }
    }
    cleanup();
    normalizeTree(tree);
  });

  tree.addEventListener("dragend", cleanup);

  function cleanup() {
    if (dragged) dragged.classList.remove("is-dragging");
    dragged = null;
    clearDropMarks(tree);
  }
}

function clearDropMarks(tree) {
  tree.querySelectorAll(".is-drop-before, .is-drop-after, .is-drop-inside").forEach((el) => {
    el.classList.remove("is-drop-before", "is-drop-after", "is-drop-inside");
    delete el.dataset.dropZone;
  });
}

/* Keep toggles/children consistent after a move (leaf ⇄ parent, drop empty lists). */
function normalizeTree(tree) {
  tree.querySelectorAll(".wb-tree__node").forEach((node) => {
    const ul = node.querySelector(":scope > .wb-tree__children");
    const has = ul && ul.querySelector(".wb-tree__node");
    const tog = node.querySelector(":scope > .wb-tree__row > .wb-tree__toggle");
    if (tog) tog.classList.toggle("is-leaf", !has);
    if (ul && !has) ul.remove();
  });
}

/* ---- Dual light/dark preview (isolated iframes) --------------------------- */
function renderDual(el) {
  const tpl = el.querySelector("template");
  if (!tpl) return;
  const snippet = tpl.innerHTML;
  const pad = el.dataset.pad || "20px";
  el.innerHTML = ["light", "dark"].map((t) => `
    <div class="dual__panel">
      <div class="dual__cap">${t === "light" ? "☀ Light mode" : "☾ Dark mode"}</div>
      <iframe class="dual__frame" data-theme="${t}" title="${t} preview"></iframe>
    </div>`).join("");
  el.querySelectorAll("iframe").forEach((f) => {
    const t = f.dataset.theme;
    f.addEventListener("load", () => {
      try {
        const r = f.contentDocument.documentElement;
        Object.keys(tweak).forEach((k) => { if (k.startsWith("--")) r.style.setProperty(k, tweak[k]); });
        const h = f.contentDocument.body.scrollHeight;
        if (h) f.style.height = h + "px";
      } catch (e) { /* ignore */ }
    });
    f.srcdoc =
      '<!doctype html><html class="' + (t === "dark" ? "dark" : "") + '"><head>' +
      '<meta charset="utf-8"><link rel="stylesheet" href="web-builder.css?v=' + (window.__v || "") + '">' +
      "<style>html,body{margin:0}body{padding:" + pad +
      ";background:var(--wb-canvas);color:var(--wb-fg);font-family:var(--wb-font)}</style>" +
      "</head><body>" + snippet + "</body></html>";
  });
}

/* ---- Token swatches ------------------------------------------------------- */
function renderSwatches(el) {
  const tokens = [
    ["--wb-surface", "surface"], ["--wb-canvas", "canvas"],
    ["--wb-fg", "fg"], ["--wb-fg-muted", "fg-muted"],
    ["--wb-border", "border"], ["--wb-gray-900", "gray-900"],
    ["--wb-gray-500", "gray-500"], ["--wb-gray-200", "gray-200"],
    ["--wb-success", "success"], ["--wb-danger", "danger"],
    ["--wb-warning", "warning"], ["--wb-info", "info"],
  ];
  const cs = getComputedStyle(document.documentElement);
  el.innerHTML = tokens.map(([v, name]) => {
    const val = cs.getPropertyValue(v).trim();
    return '<div class="swatch"><div class="swatch__chip" style="background:var(' + v +
      ');border-bottom:1px solid var(--wb-border)"></div>' +
      '<div class="swatch__meta"><div class="swatch__name">' + name +
      '</div><div class="swatch__val">' + val + "</div></div></div>";
  }).join("");
}

/* ---- Sticky-table demo fill ---------------------------------------------- */
function fillSticky(tbody) {
  const merchants = ["Grab", "Highlands", "Shopee", "WinMart", "Circle K",
    "Baemin", "Tiki", "Lazada", "GoJek", "The Coffee House"];
  let html = "";
  for (let i = 0; i < 14; i++) {
    const day = String(14 - (i % 14)).padStart(2, "0");
    const amt = ((Math.floor(50 + i * 37) % 900) + 50) * 1000;
    html += '<tr><td class="wb-cell-muted">' + day + "/07</td>" +
      '<td class="wb-cell-strong">' + merchants[i % merchants.length] + "</td>" +
      '<td class="wb-num wb-num--strong">−' + amt.toLocaleString("vi-VN") + " ₫</td></tr>";
  }
  tbody.innerHTML = html;
}

/* ---- Code copy (event delegation — works for injected content) ------------ */
document.addEventListener("click", (e) => {
  const btn = e.target.closest(".copy-btn");
  if (!btn) return;
  const code = btn.parentElement.querySelector("code");
  if (!code) return;
  navigator.clipboard.writeText(code.innerText).then(() => {
    const prev = btn.textContent;
    btn.textContent = "Đã copy ✓";
    setTimeout(() => (btn.textContent = prev), 1200);
  });
});

/* ---- Interactive demos (delegated, so injected pages just work) ----------- */
document.addEventListener("click", (e) => {
  /* BOC: collapse/expand a sidebar group (heading button, caret on the right). */
  const groupTog = e.target.closest("[data-group-toggle]");
  if (groupTog) {
    const collapsed = groupTog.closest(".doc-tree__group").classList.toggle("is-collapsed");
    groupTog.setAttribute("aria-expanded", String(!collapsed));
    return;
  }
  /* BOC: hide / show the whole sidebar. */
  const sideTog = e.target.closest("[data-side-toggle]");
  if (sideTog) { document.querySelector(".doc-shell").classList.toggle("is-side-hidden"); return; }

  /* Config: open the tweak drawer from an in-page button. */
  const cfgOpen = e.target.closest("[data-config-open]");
  if (cfgOpen) { document.getElementById("configDrawer").classList.add("is-open"); return; }

  /* Locked switch: block the flip and shake the lock ("can't change this"), then let it
     settle. The input stays enabled, so we cancel the toggle here. */
  const lockedSw = e.target.closest(".wb-switch--locked");
  if (lockedSw) {
    e.preventDefault();                 // cancel the checkbox toggle
    lockedSw.classList.remove("is-denied");
    void lockedSw.offsetWidth;          // reflow so the shake animation restarts
    lockedSw.classList.add("is-denied");
    clearTimeout(lockedSw._denyT);
    lockedSw._denyT = setTimeout(() => lockedSw.classList.remove("is-denied"), 450);
    return;
  }

  /* Tree: expand / collapse a node (works for every tree, draggable or not). */
  const treeTog = e.target.closest(".wb-tree__toggle");
  if (treeTog) { treeTog.closest(".wb-tree__node").classList.toggle("is-collapsed"); return; }

  /* Dropdown: toggle nearest .wb-dropdown; close others. */
  const ddToggle = e.target.closest("[data-dd-toggle]");
  document.querySelectorAll(".wb-dropdown.is-open").forEach((d) => {
    if (!ddToggle || d !== ddToggle.closest(".wb-dropdown")) d.classList.remove("is-open");
  });
  if (ddToggle) { ddToggle.closest(".wb-dropdown").classList.toggle("is-open"); return; }

  /* Modal: open / close. */
  const open = e.target.closest("[data-modal-open]");
  if (open) { const m = document.querySelector(open.getAttribute("data-modal-open"));
    if (m) m.classList.add("is-open"); return; }
  if (e.target.closest("[data-modal-close]") ||
      (e.target.classList && e.target.classList.contains("wb-overlay"))) {
    const ov = e.target.closest(".wb-overlay");
    if (ov) ov.classList.remove("is-open");
    return;
  }

  /* Toast: spawn a transient toast. */
  const toastBtn = e.target.closest("[data-toast]");
  if (toastBtn) { spawnToast(toastBtn.dataset); return; }

  /* Tabs: activate clicked tab + its panel inside the [data-tabs] group. */
  const tab = e.target.closest(".wb-tab");
  if (tab && tab.dataset.tab) {
    const group = tab.closest("[data-tabs]");
    if (group) {
      group.querySelectorAll(".wb-tab").forEach((t) => t.classList.toggle("is-active", t === tab));
      group.querySelectorAll("[data-panel]").forEach((p) =>
        (p.hidden = p.dataset.panel !== tab.dataset.tab));
    }
  }
});

function spawnToast(d) {
  let toaster = document.querySelector(".wb-toaster");
  if (!toaster) { toaster = document.createElement("div"); toaster.className = "wb-toaster";
    document.body.appendChild(toaster); }
  const tone = d.toast || "info";
  const icons = { success: "check", warning: "priority_high", danger: "close", info: "info" };
  const el = document.createElement("div");
  el.className = "wb-toast wb-toast--" + tone;
  el.innerHTML =
    '<span class="wb-toast__icon"><span class="wb-ico wb-ico--xs">' + (icons[tone] || "info") + "</span></span>" +
    '<div class="wb-toast__body"><p class="wb-toast__title">' + (d.title || "Thông báo") +
    '</p><p class="wb-toast__msg">' + (d.msg || "") + "</p></div>" +
    '<button class="wb-close" aria-label="Đóng"></button>';
  el.querySelector(".wb-close").addEventListener("click", () => el.remove());
  toaster.appendChild(el);
  setTimeout(() => el.remove(), 3800);
}

/* ---- Config / tweak drawer -------------------------------------------------
   A slide-out panel that fine-tunes docs-facing tokens live, then exports a .md
   the user hands to an AI (or applies by hand). It ONLY sets CSS variables on the
   docs root — it never edits web-builder.css, so the shipped primitives are untouched. */
const CONFIG_GROUPS = [
  { title: "Kiểu góc (bo góc)", rows: [
    { k: "corner-preset", label: "Kiểu góc", type: "corner",
      options: [["", "Bo tròn (mặc định)"], ["sharp", "Vuông sắc (0)"], ["soft", "Bo nhiều"]] },
    { k: "--wb-radius-sm", label: "Radius nhỏ", type: "range", min: 0, max: 16, step: 1, unit: "px" },
    { k: "--wb-radius", label: "Radius vừa", type: "range", min: 0, max: 22, step: 1, unit: "px" },
    { k: "--wb-radius-lg", label: "Radius lớn", type: "range", min: 0, max: 28, step: 1, unit: "px" },
    { k: "--wb-btn-radius", label: "Radius nút", type: "range", min: 0, max: 22, step: 1, unit: "px" },
    { k: "--wb-card-radius", label: "Radius card", type: "range", min: 0, max: 28, step: 1, unit: "px" },
    { k: "--wb-input-radius", label: "Radius input", type: "range", min: 0, max: 22, step: 1, unit: "px" },
  ]},
  { title: "Viền", rows: [
    { k: "--wb-bw", label: "Độ dày viền", type: "range", min: 0, max: 3, step: 1, unit: "px" },
    { k: "--wb-check-bw", label: "Viền checkbox", type: "range", min: 1, max: 4, step: 1, unit: "px" },
    { k: "--wb-border", label: "Màu viền", type: "color" },
    { k: "--wb-border-strong", label: "Màu viền đậm", type: "color" },
  ]},
  { title: "Đổ bóng", rows: [
    { k: "--wb-shadow-sm", label: "Đổ bóng component", type: "shadow" },
  ]},
  { title: "Màu nền & chữ", rows: [
    { k: "--wb-canvas", label: "Canvas (nền ngoài)", type: "color" },
    { k: "--wb-surface", label: "Surface (thẻ)", type: "color" },
    { k: "--wb-surface-2", label: "Surface phụ", type: "color" },
    { k: "--wb-fg", label: "Chữ chính", type: "color" },
    { k: "--wb-fg-muted", label: "Chữ phụ", type: "color" },
    { k: "--wb-fg-subtle", label: "Chữ mờ", type: "color" },
  ]},
  { title: "Màu trạng thái", rows: [
    { k: "--wb-success", label: "Success", type: "color" },
    { k: "--wb-danger", label: "Danger", type: "color" },
    { k: "--wb-warning", label: "Warning", type: "color" },
    { k: "--wb-info", label: "Info", type: "color" },
  ]},
  { title: "Chữ & icon", rows: [
    { k: "--wb-font", label: "Font", type: "font" },
    { k: "--wb-ico-size", label: "Cỡ icon", type: "range", min: 14, max: 28, step: 1, unit: "px" },
    { k: "--wb-ico-weight", label: "Độ đậm icon", type: "range", min: 300, max: 700, step: 100 },
  ]},
  { title: "Biểu đồ", rows: [
    { k: "chart-scheme", label: "Thang màu", type: "select",
      options: [["", "Đa sắc"], ["mono", "Thang xám"], ["blue", "Một tông xanh"]] },
    { k: "--wb-chart-income", label: "Màu Thu", type: "color" },
    { k: "--wb-chart-expense", label: "Màu Chi", type: "color" },
  ]},
  { title: "Chỉ trong docs", rows: [
    { k: "--wb-demo-bw", label: "Viền sample", type: "range", min: 0, max: 3, step: 1, unit: "px" },
    { k: "--wb-demo-shadow", label: "Đổ bóng sample", type: "shadow" },
    { k: "--wb-doc-divider", label: "Màu divider", type: "color" },
  ]},
];
const FONT_OPTIONS = [
  ["", "Hệ thống (mặc định)"],
  ["Inter, sans-serif", "Inter"],
  ['"Plus Jakarta Sans", sans-serif', "Plus Jakarta Sans"],
  ['"IBM Plex Sans", sans-serif', "IBM Plex Sans"],
  ["Manrope, sans-serif", "Manrope"],
  ['"DM Sans", sans-serif', "DM Sans"],
  ['"Public Sans", sans-serif', "Public Sans"],
  ["Lexend, sans-serif", "Lexend"],
  ['"Space Grotesk", sans-serif', "Space Grotesk"],
  ["Roboto, sans-serif", "Roboto"],
  ['"Source Sans 3", sans-serif', "Source Sans 3"],
];
const SHADOW_PRESETS = {
  none: "none",
  soft: "0 1px 2px rgba(16,17,18,.05), 0 1px 3px rgba(16,17,18,.04)",
  medium: "0 2px 4px rgba(16,17,18,.05), 0 6px 16px rgba(16,17,18,.08)",
};
/* Every radius token the corner presets touch (incl. the controls we just tokenised). */
const RADIUS_KEYS = ["--wb-radius-sm", "--wb-radius", "--wb-radius-lg", "--wb-radius-pill",
  "--wb-btn-radius", "--wb-card-radius", "--wb-input-radius",
  "--wb-switch-radius", "--wb-switch-thumb-radius", "--wb-check-radius",
  "--wb-range-radius", "--wb-range-thumb-radius"];
const CORNER_PRESETS = {
  sharp: { "--wb-radius-sm": "0px", "--wb-radius": "0px", "--wb-radius-lg": "0px", "--wb-radius-pill": "0px",
    "--wb-btn-radius": "0px", "--wb-card-radius": "0px", "--wb-input-radius": "0px",
    "--wb-switch-radius": "0px", "--wb-switch-thumb-radius": "0px", "--wb-check-radius": "0px",
    "--wb-range-radius": "0px", "--wb-range-thumb-radius": "0px" },
  soft: { "--wb-radius-sm": "10px", "--wb-radius": "16px", "--wb-radius-lg": "22px",
    "--wb-btn-radius": "12px", "--wb-card-radius": "20px", "--wb-input-radius": "12px",
    "--wb-check-radius": "7px" },
};
const CONFIG_DEFAULTS = {
  "--wb-ico-size": 20, "--wb-ico-weight": 600,
  "--wb-radius-sm": 6, "--wb-radius": 10, "--wb-radius-lg": 14,
  "--wb-btn-radius": 6, "--wb-card-radius": 14, "--wb-input-radius": 6,
  "--wb-bw": 1, "--wb-check-bw": 2, "--wb-demo-bw": 1,
};
const tweak = {};   /* var/key -> value the user has overridden this session */

function rgbToHex(rgb) {
  const m = String(rgb).match(/\d+/g);
  if (!m) return "#000000";
  return "#" + m.slice(0, 3).map((n) => (+n).toString(16).padStart(2, "0")).join("");
}
function resolveColor(k) {
  const probe = document.createElement("span");
  probe.style.cssText = "display:none;color:var(" + k + ")";
  document.body.appendChild(probe);
  const hex = rgbToHex(getComputedStyle(probe).color);
  probe.remove();
  return hex;
}
function setVar(k, v) { tweak[k] = v; document.documentElement.style.setProperty(k, v); }

/* Push current tweaks into each isolated light/dark preview iframe — CSS custom
   properties don't cross the iframe boundary, so we mirror them by hand. */
function mirrorToFrames() {
  document.querySelectorAll(".dual iframe").forEach((f) => {
    let r; try { r = f.contentDocument && f.contentDocument.documentElement; } catch (e) { return; }
    if (!r) return;
    Object.keys(tweak).forEach((k) => { if (k.startsWith("--")) r.style.setProperty(k, tweak[k]); });
  });
}
/* Re-read token swatches so their printed values don't go stale after a tweak. */
function refreshSwatches() { document.querySelectorAll("[data-swatches]").forEach(renderSwatches); }
/* Reflect current radius values back onto the panel's radius sliders. */
function syncRadiusSliders() {
  document.querySelectorAll('.doc-config__body input[data-type="range"]').forEach((el) => {
    const k = el.dataset.k;
    if (!k || k.indexOf("radius") === -1) return;
    let v = tweak[k]; if (v == null) v = CONFIG_DEFAULTS[k];
    v = parseInt(v, 10); if (isNaN(v)) v = 0;
    el.value = v;
    const o = el.parentNode.querySelector(".doc-config__out");
    if (o) o.textContent = v + (el.dataset.unit || "");
  });
}
/* Corner-style preset: clear every radius override, then apply the chosen preset map. */
function applyCorner(preset) {
  RADIUS_KEYS.forEach((k) => { delete tweak[k]; document.documentElement.style.removeProperty(k); });
  const map = CORNER_PRESETS[preset];
  if (map) Object.keys(map).forEach((k) => setVar(k, map[k]));
  tweak["corner-preset"] = preset;
  syncRadiusSliders();
}

function renderConfigRow(r) {
  let ctrl = "";
  if (r.type === "range") {
    const v = CONFIG_DEFAULTS[r.k];
    ctrl = '<input type="range" class="wb-range wb-range--sm" data-k="' + r.k + '" data-type="range" data-unit="' + (r.unit || "") +
      '" min="' + r.min + '" max="' + r.max + '" step="' + r.step + '" value="' + v + '">' +
      '<output class="doc-config__out">' + v + (r.unit || "") + "</output>";
  } else if (r.type === "color") {
    ctrl = '<input type="color" class="wb-color wb-color--sm" data-k="' + r.k + '" data-type="color">';
  } else if (r.type === "font") {
    ctrl = '<select data-k="--wb-font" data-type="raw">' +
      FONT_OPTIONS.map((o) => '<option value=\'' + o[0] + "'>" + o[1] + "</option>").join("") + "</select>";
  } else if (r.type === "shadow") {
    ctrl = '<select data-k="' + r.k + '" data-type="shadow">' +
      '<option value="soft">Nhẹ</option><option value="medium">Vừa</option><option value="none">Tắt</option></select>';
  } else if (r.type === "select") {
    ctrl = '<select data-k="' + r.k + '" data-type="' + (r.k === "chart-scheme" ? "scheme" : "raw") + '">' +
      r.options.map((o) => '<option value="' + o[0] + '">' + o[1] + "</option>").join("") + "</select>";
  } else if (r.type === "corner") {
    ctrl = '<select data-k="corner-preset" data-type="corner">' +
      r.options.map((o) => '<option value="' + o[0] + '">' + o[1] + "</option>").join("") + "</select>";
  }
  return '<label class="doc-config__row"><span class="doc-config__label">' + r.label + "</span>" + ctrl + "</label>";
}
function renderConfigGroup(g) {
  return '<div class="doc-config__group"><div class="doc-config__gtitle">' + g.title + "</div>" +
    g.rows.map(renderConfigRow).join("") + "</div>";
}
function onConfigInput(e) {
  const el = e.target, k = el.dataset.k, type = el.dataset.type;
  if (!k) return;
  if (type === "range") {
    const val = el.value + (el.dataset.unit || "");
    setVar(k, val);
    const out = el.parentNode.querySelector(".doc-config__out");
    if (out) out.textContent = val;
  } else if (type === "color") {
    setVar(k, el.value);
  } else if (type === "raw") {
    if (el.value) setVar(k, el.value);
    else { delete tweak[k]; document.documentElement.style.removeProperty(k); }
  } else if (type === "shadow") {
    setVar(k, SHADOW_PRESETS[el.value] || "none");
  } else if (type === "scheme") {
    const r = document.documentElement;
    r.classList.remove("wb-chart-scheme--mono", "wb-chart-scheme--blue");
    if (el.value) r.classList.add("wb-chart-scheme--" + el.value);
    tweak["chart-scheme"] = el.value;
  } else if (type === "corner") {
    applyCorner(el.value);
  }
  mirrorToFrames();
  refreshSwatches();
}
function exportConfig() {
  const keys = Object.keys(tweak).filter((k) => k.startsWith("--"));
  const theme = document.documentElement.classList.contains("dark") ? "dark" : "light";
  const L = ["# Web Builder — tinh chỉnh (tweak) tokens", ""];
  if (!keys.length && !tweak["chart-scheme"]) {
    L.push("_Chưa chỉnh gì._");
  } else {
    L.push("Dán khối này vào `:root` trong `web-builder.css` (hoặc đưa cho AI để cập nhật source):", "");
    L.push("```css", (theme === "dark" ? ".dark {" : ":root {"));
    keys.forEach((k) => L.push("  " + k + ": " + tweak[k] + ";"));
    L.push("}", "```", "");
    if (tweak["chart-scheme"]) L.push("- Thang màu biểu đồ: **" + tweak["chart-scheme"] +
      "** → thêm class `.wb-chart-scheme--" + tweak["chart-scheme"] + "` lên wrapper của chart.", "");
    L.push("> Màu ở trên áp dụng cho theme **" + theme + "**. Muốn chỉnh theme còn lại: đổi theme rồi xuất tiếp.");
  }
  const a = document.createElement("a");
  a.href = URL.createObjectURL(new Blob([L.join("\n")], { type: "text/markdown" }));
  a.download = "web-builder-tweaks.md";
  a.click();
  URL.revokeObjectURL(a.href);
}
function resetConfig() {
  Object.keys(tweak).forEach((k) => { if (k.startsWith("--")) document.documentElement.style.removeProperty(k); });
  document.documentElement.classList.remove("wb-chart-scheme--mono", "wb-chart-scheme--blue");
  Object.keys(tweak).forEach((k) => delete tweak[k]);
  document.querySelectorAll(".doc-config__body [data-k]").forEach((el) => {
    const k = el.dataset.k, type = el.dataset.type;
    if (type === "range") {
      el.value = CONFIG_DEFAULTS[k];
      const o = el.parentNode.querySelector(".doc-config__out");
      if (o) o.textContent = CONFIG_DEFAULTS[k] + (el.dataset.unit || "");
    } else if (type === "color") { el.value = resolveColor(k); }
    else { el.selectedIndex = 0; }
  });
  mirrorToFrames();
  refreshSwatches();
}
function initConfig() {
  const drawer = document.getElementById("configDrawer");
  if (!drawer || drawer.dataset.ready) return;
  drawer.dataset.ready = "1";
  const body = drawer.querySelector(".doc-config__body");
  body.innerHTML = CONFIG_GROUPS.map(renderConfigGroup).join("");
  body.addEventListener("input", onConfigInput);
  body.addEventListener("change", onConfigInput);
  drawer.querySelectorAll('input[type="color"][data-k]').forEach((inp) => { inp.value = resolveColor(inp.dataset.k); });
  drawer.querySelector("[data-config-export]").addEventListener("click", exportConfig);
  drawer.querySelector("[data-config-reset]").addEventListener("click", resetConfig);
  drawer.querySelector("[data-config-close]").addEventListener("click", () => drawer.classList.remove("is-open"));
}

/* ---- Theme toggle --------------------------------------------------------- */
const root = document.documentElement;
function applyThemeLabel() {
  const dark = root.classList.contains("dark");
  document.getElementById("themeIcon").textContent = dark ? "☾" : "☀";
  document.getElementById("themeLabel").textContent = dark ? "Dark" : "Light";
}
function toggleTheme() {
  root.classList.toggle("dark");
  localStorage.setItem("wb-theme", root.classList.contains("dark") ? "dark" : "light");
  applyThemeLabel();
}

/* ---- Boot ----------------------------------------------------------------- */
renderNav();
applyThemeLabel();
initConfig();
document.getElementById("themeBtn").addEventListener("click", toggleTheme);
const cfgBtn = document.getElementById("configBtn");
if (cfgBtn) cfgBtn.addEventListener("click", () =>
  document.getElementById("configDrawer").classList.toggle("is-open"));
window.addEventListener("hashchange", loadRoute);
loadRoute();
