
/* file: config.js */
// =====================================================================
// Firebase configuration - matches lib/firebase_options.dart
// NOTE: The current platform config uses the Android appId. For web,
// we use the web app config. The apiKey/projectId are the same project.
// =====================================================================
window.FB_CONFIG = {
  apiKey: 'AIzaSyCXc2NqXW9DuJVzM7S18XUbpgNoOt38ZLA',
  authDomain: 'qlvt-4d1fc.firebaseapp.com',
  projectId: 'qlvt-4d1fc',
  storageBucket: 'qlvt-4d1fc.firebasestorage.app',
  messagingSenderId: '111742463162',
  appId: '1:111742463162:web:auto',
};

// Local accounts (same as LoginController in Flutter)
window.LOCAL_ACCOUNTS = {
  owner: { password: '123', role: 'owner', displayName: 'Chủ' },
  ketoan1: { password: '123', role: 'accountant', displayName: 'Kế toán 1' },
  ketoan2: { password: '123', role: 'accountant', displayName: 'Kế toán 2' },
  user1: { password: '123', role: 'user', displayName: 'User 1' },
  user2: { password: '123', role: 'user', displayName: 'User 2' },
};

// Firebase email users mapped to roles (same as Flutter logic)
window.EMAIL_ROLES = {
  'owner@qlvt.app': 'owner',
  'accountant@qlvt.app': 'accountant',
  'ketoan@qlvt.app': 'accountant',
};

// Firestore collection names (must match existing Flutter app)
window.COLLECTIONS = {
  materials: 'materials',
  products: 'products',
  suppliers: 'suppliers',
  deliveries: 'deliveries',
  notifications: 'notifications',
};


/* file: firebase.js */
// =====================================================================
// Firebase initialization + Auth/Firestore wrappers
// =====================================================================

let FB = window.firebase;

const Fire = {
  _initialized: false,
  _configured: false,
  app: null,
  auth: null,
  db: null,

  init() {
    if (this._initialized) return;
    try {
      this.app = FB.initializeApp(window.FB_CONFIG);
      this.auth = FB.auth(this.app);
      this.db = FB.firestore(this.app);
      this._configured = true;
      // Enable persistence (offline cache) — best effort
      try {
        FB.enableIndexedDbPersistence(this.db).catch(() => {});
      } catch (e) {
        // ignore
      }
    } catch (e) {
      console.error('Firebase init error:', e);
      this._configured = false;
    }
    this._initialized = true;
  },

  get isConfigured() {
    return this._configured;
  },

  // ---- Auth ----
  async signInEmailPassword(email, password) {
    if (!this._configured) throw new Error('Firebase chưa được cấu hình.');
    const cred = await this.auth.signInWithEmailAndPassword(email, password);
    return cred.user;
  },

  async signInAnonymously() {
    if (!this._configured) return null;
    try {
      const cred = await this.auth.signInAnonymously();
      return cred.user;
    } catch (e) {
      return null;
    }
  },

  async signOut() {
    if (!this._configured) return;
    try {
      await this.auth.signOut();
    } catch (e) {
      // ignore
    }
  },

  // ---- Firestore helpers ----
  col(name) {
    return FB.collection(this.db, name);
  },
  doc(collPath, id) {
    return FB.doc(this.db, collPath, id);
  },
  async getDocs(name, limit = 200) {
    let q = FB.collection(this.db, name);
    if (limit && limit > 0) q = FB.query(q, FB.limit(limit));
    const snap = await FB.getDocs(q);
    const out = [];
    snap.forEach((d) => out.push({ ...d.data(), __id: d.id }));
    return out;
  },
  async addDoc(name, id, data) {
    const ref = this.doc(name, String(id));
    await FB.setDoc(ref, data);
  },
  async updateDoc(name, id, data) {
    const ref = this.doc(name, String(id));
    await FB.setDoc(ref, data, { merge: true });
  },
  async deleteDoc(name, id) {
    await FB.deleteDoc(this.doc(name, String(id)));
  },
  async deleteAll(name) {
    const snap = await FB.getDocs(FB.collection(this.db, name));
    for (const d of snap.docs) await FB.deleteDoc(d.ref);
  },
  // Callback-based realtime
  onSnapshot(name, cb, err) {
    const q = FB.query(
      FB.collection(this.db, name),
      FB.orderBy('timestamp', 'desc'),
      FB.limit(50)
    );
    return FB.onSnapshot(
      q,
      (snap) => {
        const out = [];
        snap.forEach((d) => out.push({ ...d.data(), __id: d.id }));
        cb(out);
      },
      err
    );
  },
};

// Prevent accidental "BFB" typo breaking
// Fix: deleteAll should use this.db
window.Fire = Fire;


/* file: store.js */
// =====================================================================
// Store = Data service layer (mirrors FirestoreDataService in Flutter)
// Handles collections, caching, notifications
// =====================================================================

const Store = {
  // Caches
  _materialsCache: null,
  _productsCache: null,
  _suppliersCache: null,
  _deliveriesCache: null,
  _preloaded: false,

  // ---- Init / Preload ----
  async preload() {
    if (this._preloaded) return;
    try {
      await Promise.all([
        this.getMaterials(),
        this.getProducts(),
        this.getSuppliers(),
        this.getDeliveries(),
      ]);
    } catch (e) {
      console.warn('Preload failed', e);
    }
    this._preloaded = true;
  },

  resetPreload() {
    this._preloaded = false;
    this._materialsCache = null;
    this._productsCache = null;
    this._suppliersCache = null;
    this._deliveriesCache = null;
  },

  // ---- ID generation (same as Flutter: millis since epoch) ----
  newId() {
    return Date.now().toString();
  },

  safeInt(v) {
    if (typeof v === 'number') return v;
    if (typeof v === 'string') {
      const n = parseInt(v, 10);
      if (!isNaN(n)) return n;
    }
    return Date.now();
  },

  parseDate(v) {
    if (!v) return new Date();
    if (v instanceof Date) return v;
    // Firestore Timestamp-like object
    if (typeof v === 'object' && typeof v.toDate === 'function') return v.toDate();
    if (typeof v === 'object' && v.seconds) return new Date(v.seconds * 1000);
    try { return new Date(v); } catch (e) { return new Date(); }
  },

  // ---- Materials ----
  async getMaterials() {
    const c = this._materialsCache;
    if (c) return c;
    try {
      const docs = await Fire.getDocs(window.COLLECTIONS.materials, 200);
      const list = docs.map((d) => ({
        id: this.safeInt(d.id ?? d.__id),
        maVatTu: d.maVatTu || '',
        tenVatTu: d.tenVatTu || '',
        nhomVatTu: d.nhomVatTu || '',
        donViTinh: d.donViTinh || '',
        soLuongTon: d.soLuongTon || 0,
        mucCanhBao: d.mucCanhBao || 0,
        giaNhap: d.giaNhap || 0,
        nhaCungCap: d.nhaCungCap || '',
      }));
      list.sort((a, b) => a.tenVatTu.toLowerCase().localeCompare(b.tenVatTu.toLowerCase()));
      this._materialsCache = list;
      return list;
    } catch (e) {
      console.warn('getMaterials failed', e);
      return [];
    }
  },
  refreshMaterials() {
    this._materialsCache = null;
    return this.getMaterials();
  },
  async addMaterial(m) {
    const id = this.newId();
    const data = { ...m, id: parseInt(id) };
    await Fire.addDoc(window.COLLECTIONS.materials, id, data);
    this._materialsCache = null;
    await this.addNotification({
      action: 'add',
      description: `Thêm vật tư mới: ${m.tenVatTu}`,
      targetType: 'material',
      targetId: id,
      targetName: m.tenVatTu,
    });
    return id;
  },
  async updateMaterial(m) {
    await Fire.updateDoc(window.COLLECTIONS.materials, m.id, m);
    this._materialsCache = null;
    await this.addNotification({
      action: 'update',
      description: `Cập nhật vật tư: ${m.tenVatTu}`,
      targetType: 'material',
      targetId: m.id,
      targetName: m.tenVatTu,
    });
  },
  async deleteMaterial(id) {
    await Fire.deleteDoc(window.COLLECTIONS.materials, id);
    this._materialsCache = null;
    await this.addNotification({
      action: 'delete',
      description: `Xóa vật tư ID: ${id}`,
      targetType: 'material',
      targetId: id,
      targetName: `Vật tư #${id}`,
    });
  },

  // ---- Products ----
  async getProducts() {
    const c = this._productsCache;
    if (c) return c;
    try {
      const docs = await Fire.getDocs(window.COLLECTIONS.products, 200);
      const list = docs.map((d) => ({
        id: this.safeInt(d.id ?? d.__id),
        maSanPham: d.maSanPham || '',
        tenSanPham: d.tenSanPham || '',
        donVi: d.donVi || '',
        soKien: d.soKien || 0,
        diaChiLapRap: d.diaChiLapRap || '',
        ngayTao: this.parseDate(d.ngayTao).toISOString(),
      }));
      list.sort((a, b) => a.tenSanPham.toLowerCase().localeCompare(b.tenSanPham.toLowerCase()));
      this._productsCache = list;
      return list;
    } catch (e) {
      console.warn('getProducts failed', e);
      return [];
    }
  },
  refreshProducts() {
    this._productsCache = null;
    return this.getProducts();
  },
  async addProduct(p) {
    const id = this.newId();
    const data = { ...p, id: parseInt(id) };
    await Fire.addDoc(window.COLLECTIONS.products, id, data);
    this._productsCache = null;
    await this.addNotification({
      action: 'add',
      description: `Thêm thành phẩm mới: ${p.tenSanPham}`,
      targetType: 'product',
      targetId: id,
      targetName: p.tenSanPham,
    });
    return id;
  },
  async updateProduct(p) {
    await Fire.updateDoc(window.COLLECTIONS.products, p.id, p);
    this._productsCache = null;
    await this.addNotification({
      action: 'update',
      description: `Cập nhật thành phẩm: ${p.tenSanPham}`,
      targetType: 'product',
      targetId: p.id,
      targetName: p.tenSanPham,
    });
  },
  async deleteProduct(id) {
    await Fire.deleteDoc(window.COLLECTIONS.products, id);
    this._productsCache = null;
    await this.addNotification({
      action: 'delete',
      description: `Xóa thành phẩm ID: ${id}`,
      targetType: 'product',
      targetId: id,
      targetName: `Thành phẩm #${id}`,
    });
  },

  // ---- Suppliers ----
  async getSuppliers() {
    const c = this._suppliersCache;
    if (c) return c;
    try {
      const docs = await Fire.getDocs(window.COLLECTIONS.suppliers, 200);
      const list = docs.map((d) => ({
        id: this.safeInt(d.id ?? d.__id),
        maNCC: d.maNCC || '',
        tenNCC: d.tenNCC || '',
        diaChi: d.diaChi || '',
        soDienThoai: d.soDienThoai || '',
        email: d.email || '',
        nguoiLienHe: d.nguoiLienHe || '',
        ghiChu: d.ghiChu || '',
        ngayTao: this.parseDate(d.ngayTao).toISOString(),
      }));
      list.sort((a, b) => a.tenNCC.toLowerCase().localeCompare(b.tenNCC.toLowerCase()));
      this._suppliersCache = list;
      return list;
    } catch (e) {
      console.warn('getSuppliers failed', e);
      return [];
    }
  },
  refreshSuppliers() {
    this._suppliersCache = null;
    return this.getSuppliers();
  },
  async addSupplier(s) {
    const id = this.newId();
    const data = { ...s, id: parseInt(id) };
    await Fire.addDoc(window.COLLECTIONS.suppliers, id, data);
    this._suppliersCache = null;
    await this.addNotification({
      action: 'add',
      description: `Thêm nhà cung cấp mới: ${s.tenNCC}`,
      targetType: 'supplier',
      targetId: id,
      targetName: s.tenNCC,
    });
    return id;
  },
  async updateSupplier(s) {
    await Fire.updateDoc(window.COLLECTIONS.suppliers, s.id, s);
    this._suppliersCache = null;
    await this.addNotification({
      action: 'update',
      description: `Cập nhật nhà cung cấp: ${s.tenNCC}`,
      targetType: 'supplier',
      targetId: s.id,
      targetName: s.tenNCC,
    });
  },
  async deleteSupplier(id) {
    await Fire.deleteDoc(window.COLLECTIONS.suppliers, id);
    this._suppliersCache = null;
    await this.addNotification({
      action: 'delete',
      description: `Xóa nhà cung cấp ID: ${id}`,
      targetType: 'supplier',
      targetId: id,
      targetName: `Nhà cung cấp #${id}`,
    });
  },

  // ---- Deliveries ----
  async getDeliveries() {
    const c = this._deliveriesCache;
    if (c) return c;
    try {
      const docs = await Fire.getDocs(window.COLLECTIONS.deliveries, 200);
      const list = docs.map((d) => ({
        id: this.safeInt(d.id ?? d.__id),
        tenSanPham: d.tenSanPham || '',
        soKien: d.soKien || 0,
        diaChiGiao: d.diaChiGiao || '',
        nguoiBocHang: d.nguoiBocHang || '',
        taiXe: d.taiXe || '',
        bienSoXe: d.bienSoXe || '',
        thoiGian: this.parseDate(d.thoiGian).toISOString(),
        ghiChu: d.ghiChu || '',
        imagePath: d.imagePath || null,
      }));
      list.sort((a, b) => new Date(b.thoiGian) - new Date(a.thoiGian));
      this._deliveriesCache = list;
      return list;
    } catch (e) {
      console.warn('getDeliveries failed', e);
      return [];
    }
  },
  refreshDeliveries() {
    this._deliveriesCache = null;
    return this.getDeliveries();
  },
  async addDelivery(d) {
    const id = this.newId();
    const data = { ...d, id: parseInt(id) };
    await Fire.addDoc(window.COLLECTIONS.deliveries, id, data);
    this._deliveriesCache = null;
    await this.addNotification({
      action: 'deliver',
      description: `Tạo phiếu giao: ${d.tenSanPham} (${d.soKien} kiện)`,
      targetType: 'delivery',
      targetId: id,
      targetName: d.tenSanPham,
    });
    return id;
  },
  async updateDelivery(d) {
    await Fire.updateDoc(window.COLLECTIONS.deliveries, d.id, d);
    this._deliveriesCache = null;
    await this.addNotification({
      action: 'update',
      description: `Cập nhật phiếu giao: ${d.tenSanPham}`,
      targetType: 'delivery',
      targetId: d.id,
      targetName: d.tenSanPham,
    });
  },
  async deleteDelivery(id) {
    await Fire.deleteDoc(window.COLLECTIONS.deliveries, id);
    this._deliveriesCache = null;
    await this.addNotification({
      action: 'delete',
      description: `Xóa phiếu giao ID: ${id}`,
      targetType: 'delivery',
      targetId: id,
      targetName: `Phiếu giao #${id}`,
    });
  },
  async clearDeliveries() {
    await Fire.deleteAll(window.COLLECTIONS.deliveries);
    this._deliveriesCache = null;
  },

  // ---- Notifications ----
  async addNotification({ action, description, targetType, targetId, targetName }) {
    try {
      const user = Auth.currentUser;
      if (!user) return;
      const id = this.newId();
      const notif = {
        id,
        action,
        description,
        userName: user.username,
        displayName: user.displayName,
        userRole: user.role,
        timestamp: new Date(),
        targetType,
        targetId: String(targetId),
        targetName,
      };
      await Fire.addDoc(window.COLLECTIONS.notifications, id, notif);
    } catch (e) {
      console.warn('addNotification failed', e);
    }
  },

async getNotifications(limit = 50) {
    try {
      const docs = await Fire.getDocs(window.COLLECTIONS.notifications, limit);
      return docs
        .map((d) => ({
          id: d.__id || '',
          action: d.action || '',
          description: d.description || '',
          userName: d.userName || '',
          displayName: d.displayName || '',
          userRole: d.userRole || '',
          timestamp: this.parseDate(d.timestamp),
          targetType: d.targetType || '',
          targetId: String(d.targetId ?? ''),
          targetName: d.targetName || '',
        }))
        .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
    } catch (e) {
      console.warn('getNotifications failed', e);
      return [];
    }
  },

async getUnreadNotificationCount() {
    // Count notifications in last 24h (matching Flutter behavior roughly)
    const all = await this.getNotifications(200);
    const dayAgo = Date.now() - 24 * 3600 * 1000;
    return all.filter((n) => new Date(n.timestamp).getTime() >= dayAgo).length;
  },

  // Real-time notifications subscription (callback-based)
  streamNotifications(cb) {
    return Fire.onSnapshot(
      window.COLLECTIONS.notifications,
      (docs) => {
        const list = docs
          .map((n) => ({
            id: n.__id || '',
            action: n.action || '',
            description: n.description || '',
            userName: n.userName || '',
            displayName: n.displayName || '',
            userRole: n.userRole || '',
            timestamp: this.parseDate(n.timestamp),
            targetType: n.targetType || '',
            targetId: String(n.targetId ?? ''),
            targetName: n.targetName || '',
          }))
          .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
        cb(list);
      },
      (err) => console.warn('notification stream error', err)
    );
  },

  // ---- Counts (aggregate, với fallback) ----
  // Tối ưu: ưu tiên dùng cache đã có từ preload/getX, tránh truy vấn Firestore lặp.
  async _aggregateCount(name) {
    // Sử dụng cache tương ứng nếu đã có dữ liệu
    if (name === window.COLLECTIONS.materials && this._materialsCache) {
      return this._materialsCache.length;
    }
    if (name === window.COLLECTIONS.products && this._productsCache) {
      return this._productsCache.length;
    }
    if (name === window.COLLECTIONS.suppliers && this._suppliersCache) {
      return this._suppliersCache.length;
    }
    if (name === window.COLLECTIONS.deliveries && this._deliveriesCache) {
      return this._deliveriesCache.length;
    }
    // Fallback: đếm qua getDocs
    try {
      const docs = await Fire.getDocs(name, undefined);
      return docs.length;
    } catch (e) {
      return 0;
    }
  },
  countMaterials() {
    return this._aggregateCount(window.COLLECTIONS.materials);
  },
  countProducts() {
    return this._aggregateCount(window.COLLECTIONS.products);
  },
  countSuppliers() {
    return this._aggregateCount(window.COLLECTIONS.suppliers);
  },
  countDeliveries() {
    return this._aggregateCount(window.COLLECTIONS.deliveries);
  },
};

window.Store = Store;


/* file: auth.js */
// =====================================================================
// Auth = session management (mirrors AuthService + LoginController)
// =====================================================================

const Auth = {
  currentUser: null,
  _sessionKey: 'qlvt_web_session',

  snapshot() {
    return this.currentUser;
  },

  get isLoggedIn() {
    return this.currentUser != null;
  },

  get canViewUnitPrice() {
    return this.currentUser
      ? this.currentUser.role === 'owner' || this.currentUser.role === 'accountant'
      : false;
  },

  get canFullAccess() {
    return (
      this.currentUser != null &&
      (this.currentUser.role === 'owner' || this.currentUser.role === 'accountant')
    );
  },

  login(user) {
    this.currentUser = user;
    try {
      localStorage.setItem(
        this._sessionKey,
        JSON.stringify({ ...user, _type: 'local' })
      );
    } catch (e) {
      // ignore
    }
  },

  loginFirebase(fbUser) {
    const email = (fbUser.email || '').toLowerCase();
    let role = 'user';
    if (email === 'owner@qlvt.app') role = 'owner';
    else if (email === 'accountant@qlvt.app' || email === 'ketoan@qlvt.app') role = 'accountant';

    const user = {
      username: email,
      role,
      displayName: email || 'Người dùng',
    };
    this.currentUser = user;
    try {
      localStorage.setItem(
        this._sessionKey,
        JSON.stringify({ ...user, _type: 'firebase' })
      );
    } catch (e) {
      // ignore
    }
  },

  logout() {
    this.currentUser = null;
    try {
      localStorage.removeItem(this._sessionKey);
    } catch (e) {
      // ignore
    }
    Fire.signOut();
  },

  restore() {
    try {
      const raw = localStorage.getItem(this._sessionKey);
      if (!raw) return null;
      const u = JSON.parse(raw);
      if (u && u.username) {
        this.currentUser = u;
        return u;
      }
    } catch (e) {
      // ignore
    }
    return null;
  },

  // Local account login (mirrors LoginController)
  localLogin(username, password) {
    const normalized = username.trim().toLowerCase();
    const acc = window.LOCAL_ACCOUNTS[normalized];
    if (!acc) return null;
    if (acc.password !== password) return null;
    const user = {
      username: normalized,
      role: acc.role,
      displayName: acc.displayName,
    };
    this.login(user);
    return user;
  },

  // Firebase email/password login
  async firebaseLogin(email, password) {
    const user = await Fire.signInEmailPassword(email, password);
    this.loginFirebase(user);
    return user;
  },
};

window.Auth = Auth;


/* file: ui.js */
// =====================================================================
// UI helpers: toast, modal, confirm, formatters
// =====================================================================

const UI = {
  // ---- Toast ----
  toast(msg, type = 'info', duration = 3000) {
    const container = document.getElementById('toastContainer');
    const el = document.createElement('div');
    el.className = `toast ${type}`;
    el.textContent = msg;
    container.appendChild(el);
    setTimeout(() => {
      el.style.transition = 'opacity .3s';
      el.style.opacity = '0';
      setTimeout(() => el.remove(), 300);
    }, duration);
  },

  // ---- Modal ----
  openModal({ title, body, footer, maxWidth = 560, icon }) {
    const root = document.getElementById('modalRoot');
    root.innerHTML = '';
    const overlay = document.createElement('div');
    overlay.className = 'modal-overlay';
    const modal = document.createElement('div');
    modal.className = 'modal';
    modal.style.maxWidth = maxWidth + 'px';

    const header = document.createElement('div');
    header.className = 'modal-header';
    if (icon) {
      const ic = document.createElement('span');
      ic.className = 'material-symbol';
      ic.textContent = icon;
      header.appendChild(ic);
    }
    const h3 = document.createElement('h3');
    h3.textContent = title;
    header.appendChild(h3);
    const closeBtn = document.createElement('button');
    closeBtn.className = 'modal-close';
    closeBtn.innerHTML = '&times;';
    closeBtn.onclick = close;
    header.appendChild(closeBtn);

    const bodyEl = document.createElement('div');
    bodyEl.className = 'modal-body';
    if (typeof body === 'string') bodyEl.innerHTML = body;
    else bodyEl.appendChild(body);

    modal.appendChild(header);
    modal.appendChild(bodyEl);

    if (footer) {
      const footerEl = document.createElement('div');
      footerEl.className = 'modal-footer';
      if (typeof footer === 'string') footerEl.innerHTML = footer;
      else footerEl.appendChild(footer);
      modal.appendChild(footerEl);
    }

    overlay.appendChild(modal);
    root.appendChild(overlay);

    // Close on overlay click
    overlay.addEventListener('click', (e) => {
      if (e.target === overlay) close();
    });

    function close() {
      root.innerHTML = '';
    }
    return { close, overlay };
  },

  closeModal() {
    document.getElementById('modalRoot').innerHTML = '';
  },

  // ---- Confirm dialog ----
  confirm({ title, message, danger = true, confirmText = 'Xóa', cancelText = 'Hủy' }) {
    return new Promise((resolve) => {
      const body = document.createElement('div');
      const p = document.createElement('p');
      p.textContent = message;
      p.style.color = '#1c2b3a';
      body.appendChild(p);

      const footer = document.createElement('div');
      const cancelBtn = document.createElement('button');
      cancelBtn.className = 'btn btn-ghost';
      cancelBtn.textContent = cancelText;
      cancelBtn.onclick = () => { UI.closeModal(); resolve(false); };
      const okBtn = document.createElement('button');
      okBtn.className = `btn ${danger ? 'btn-danger' : 'btn-primary'}`;
      okBtn.textContent = confirmText;
      okBtn.onclick = () => { UI.closeModal(); resolve(true); };
      footer.appendChild(cancelBtn);
      footer.appendChild(okBtn);

      UI.openModal({ title, body, footer, maxWidth: 420 });
      // focus ok
      setTimeout(() => okBtn.focus(), 50);
    });
  },

  // ---- Formatters ----
  fmt(n) {
    if (n == null) return '0';
    const s = String(n);
    return s.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  },
  fmtMoney(amount) {
    if (!amount || amount <= 0) return '—';
    return this.fmt(Math.round(amount)) + ' đ';
  },
  fmtDate(dt) {
    const d = new Date(dt);
    const dd = String(d.getDate()).padStart(2, '0');
    const mm = String(d.getMonth() + 1).padStart(2, '0');
    const h = String(d.getHours()).padStart(2, '0');
    const mi = String(d.getMinutes()).padStart(2, '0');
    return `${dd}/${mm}/${d.getFullYear()} ${h}:${mi}`;
  },
  fmtDateShort(dt) {
    const d = new Date(dt);
    const dd = String(d.getDate()).padStart(2, '0');
    const mm = String(d.getMonth() + 1).padStart(2, '0');
    return `${dd}/${mm}/${d.getFullYear()}`;
  },
  timeAgo(dt) {
    const diff = Date.now() - new Date(dt).getTime();
    const min = Math.floor(diff / 60000);
    if (min < 1) return 'Vừa xong';
    if (min < 60) return `${min} phút trước`;
    const hr = Math.floor(min / 60);
    if (hr < 24) return `${hr} giờ trước`;
    const day = Math.floor(hr / 24);
    if (day < 7) return `${day} ngày trước`;
    return this.fmtDate(dt);
  },
  roleLabel(role) {
    switch (role) {
      case 'owner': return 'Chủ';
      case 'accountant': return 'Kế toán';
      default: return 'User';
    }
  },
  roleColor(role) {
    switch (role) {
      case 'owner': return '#b26a00';
      case 'accountant': return '#1565c0';
      default: return '#6b7a8c';
    }
  },
  escapeHtml(str) {
    if (str == null) return '';
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '<')
      .replace(/>/g, '>')
      .replace(/"/g, '"');
  },
};

window.UI = UI;


/* file: app.js */
// =====================================================================
// App = main shell controller + SPA router
// =====================================================================

const App = {
  currentView: 'dashboard',
  _notifUnsub: null,

  // ---- Init ----
  async init() {
    Fire.init();
    document.getElementById('loadingText').textContent = 'Đang tải ứng dụng...';

    // Render login view
    LoginView.init();

    // Restore session
    const user = Auth.restore();
    if (user) {
      this.showApp();
    } else {
      this.showLogin();
    }

    // Hide loading overlay
    setTimeout(() => {
      const overlay = document.getElementById('loadingOverlay');
      if (overlay) {
        overlay.classList.add('fade-out');
        setTimeout(() => overlay.remove(), 400);
      }
    }, 400);

    this.bindShellEvents();
  },

  // ---- Shell event binding ----
  bindShellEvents() {
    // Menu click
    document.getElementById('menuBtn').addEventListener('click', () => {
      this.openDrawer();
    });
    document.getElementById('sidebarOverlay').addEventListener('click', () => {
      this.closeDrawer();
    });
    // Sidebar menu items
    document.querySelectorAll('.menu-item').forEach((el) => {
      el.addEventListener('click', (ev) => {
        ev.preventDefault();
        const view = el.dataset.view;
        this.navigate(view);
        this.closeDrawer();
      });
    });
    // Logout
    document.getElementById('logoutBtn').addEventListener('click', () => this.logout());
    // Notification bell
    document.getElementById('notifBtn').addEventListener('click', () => {
      NotificationsView.toggle();
    });
    // Close notif panel on outside click
    document.addEventListener('click', (e) => {
      const panel = document.getElementById('notifPanel');
      const btn = document.getElementById('notifBtn');
      if (panel && !panel.classList.contains('hidden')) {
        if (!panel.contains(e.target) && !btn.contains(e.target)) {
          NotificationsView.hide();
        }
      }
    });
    // Resize handler
    window.addEventListener('resize', () => {
      if (window.innerWidth > 900) this.closeDrawer();
    });
  },

  openDrawer() {
    document.getElementById('sidebar').classList.add('open');
    document.getElementById('sidebarOverlay').classList.remove('hidden');
  },
  closeDrawer() {
    document.getElementById('sidebar').classList.remove('open');
    document.getElementById('sidebarOverlay').classList.add('hidden');
  },

  // ---- Navigation ----
  navigate(view) {
    this.currentView = view;
    // Update active menu
    document.querySelectorAll('.menu-item').forEach((el) => {
      el.classList.toggle('active', el.dataset.view === view);
    });
    // Update title
    const titles = {
      dashboard: 'Dashboard',
      materials: 'Quản lý vật tư',
      suppliers: 'Nhà cung cấp',
      products: 'Thành phẩm',
      deliveries: 'Lịch sử giao hàng',
      reports: 'Báo cáo & Thống kê',
    };
    document.getElementById('pageTitle').textContent = titles[view] || 'Dashboard';
    this.updateDate();

    // Render view
    const main = document.getElementById('mainContent');
    main.innerHTML = '';
    switch (view) {
      case 'dashboard':
        DashboardView.render(main);
        break;
      case 'materials':
        MaterialsView.render(main);
        break;
      case 'suppliers':
        SuppliersView.render(main);
        break;
      case 'products':
        ProductsView.render(main);
        break;
      case 'deliveries':
        DeliveriesView.render(main);
        break;
      case 'reports':
        ReportsView.render(main);
        break;
      default:
        DashboardView.render(main);
    }
  },

  updateDate() {
    const el = document.getElementById('todayDate');
    const days = ['Chủ Nhật', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy'];
    const now = new Date();
    const dd = String(now.getDate()).padStart(2, '0');
    const mm = String(now.getMonth() + 1).padStart(2, '0');
    el.textContent = `${days[now.getDay()]}, ${dd}/${mm}/${now.getFullYear()}`;
  },

  // ---- Login/App switching ----
  showLogin() {
    document.getElementById('loginScreen').classList.remove('hidden');
    document.getElementById('appShell').classList.add('hidden');
    document.getElementById('notifPanel').classList.add('hidden');
  },
  showApp() {
    document.getElementById('loginScreen').classList.add('hidden');
    document.getElementById('appShell').classList.remove('hidden');
    // Set user info
    const u = Auth.currentUser;
    if (u) {
      document.getElementById('userName').textContent = u.displayName;
      document.getElementById('userAvatar').textContent =
        (u.displayName || 'A')[0].toUpperCase();
    }
    // Preload data in background
    Store.preload();
    // Navigate to dashboard
    this.navigate('dashboard');
    // Start notification subscription
    this.subscribeNotifications();
  },

  logout() {
    Auth.logout();
    Store.resetPreload();
    this.showLogin();
    UI.toast('Đã đăng xuất', 'info');
  },

  // ---- Notifications ----
  subscribeNotifications() {
    if (this._notifUnsub) return;
    this._notifUnsub = true;
    const refresh = () => {
      Store.getUnreadNotificationCount().then((count) => {
        const badge = document.getElementById('notifBadge');
        if (count > 0) {
          badge.textContent = count > 99 ? '99+' : String(count);
          badge.classList.remove('hidden');
        } else {
          badge.classList.add('hidden');
        }
      });
    };
    refresh();
    setInterval(refresh, 60000);
  },
};

// Boot on DOM ready
document.addEventListener('DOMContentLoaded', () => {
  window.App = App;
  App.init();
});


/* file: login.js */
// =====================================================================
// Login view
// =====================================================================

const LoginView = {
  init() {
    // Tab switching
    document.querySelectorAll('.login-tab').forEach((tab) => {
      tab.addEventListener('click', () => {
        document.querySelectorAll('.login-tab').forEach((t) => t.classList.remove('active'));
        tab.classList.add('active');
        const which = tab.dataset.tab;
        if (which === 'local') {
          document.getElementById('localLoginForm').classList.remove('hidden');
          document.getElementById('firebaseLoginForm').classList.add('hidden');
        } else {
          document.getElementById('localLoginForm').classList.add('hidden');
          document.getElementById('firebaseLoginForm').classList.remove('hidden');
        }
      });
    });

    // Local login submit
    document.getElementById('localLoginForm').addEventListener('submit', (e) => {
      e.preventDefault();
      this.localLogin();
    });

    // Firebase login submit
    document.getElementById('firebaseLoginForm').addEventListener('submit', (e) => {
      e.preventDefault();
      this.firebaseLogin();
    });
  },

  async localLogin() {
    const username = document.getElementById('loginUsername').value;
    const password = document.getElementById('loginPassword').value;

    if (!username || !password) {
      UI.toast('Vui lòng nhập tên đăng nhập và mật khẩu.', 'warning');
      return;
    }

    const user = Auth.localLogin(username, password);
    if (!user) {
      UI.toast('Tên đăng nhập hoặc mật khẩu không đúng.', 'error');
      return;
    }

    // Navigate to app immediately (background init)
    App.showApp();
    // Anonymous sign-in + preload in background
    Fire.signInAnonymously().catch(() => {});
    Store.preload().catch(() => {});
  },

  async firebaseLogin() {
    const email = document.getElementById('fbEmail').value.trim();
    const password = document.getElementById('fbPassword').value;

    if (!email || !password) {
      UI.toast('Vui lòng nhập email và mật khẩu.', 'warning');
      return;
    }

    try {
      await Auth.firebaseLogin(email, password);
      App.showApp();
      Store.preload().catch(() => {});
    } catch (e) {
      UI.toast('Đăng nhập thất bại: ' + (e.message || 'Lỗi không xác định'), 'error');
    }
  },
};

window.LoginView = LoginView;


/* file: dashboard.js */
// =====================================================================
// Dashboard view (KPI cards + recent deliveries + warnings)
// =====================================================================

const DashboardView = {
  async render(main) {
    main.innerHTML = `
      <div class="page-header">
        <h2>Tổng quan hệ thống</h2>
        <button class="btn btn-outline btn-sm" id="dashRefresh">Làm mới</button>
      </div>
      <div id="dashLoading" class="inline-loader"><div class="spinner"></div></div>
      <div id="dashContent" class="hidden"></div>
    `;

    document.getElementById('dashRefresh').addEventListener('click', () => this.load());

    this.load();
  },

  async load() {
    const content = document.getElementById('dashContent');
    const loading = document.getElementById('dashLoading');
    if (!content) return;

    content.classList.add('hidden');
    loading.classList.remove('hidden');

    try {
      const [totalMat, totalProd, totalSup, totalDel, materials, deliveries] =
        await Promise.all([
          Store.countMaterials(),
          Store.countProducts(),
          Store.countSuppliers(),
          Store.countDeliveries(),
          Store.getMaterials(),
          Store.getDeliveries(),
        ]);

      const inventory = materials.reduce((s, m) => s + (m.soLuongTon || 0), 0);
      const warnings = materials.filter((m) => m.soLuongTon <= m.mucCanhBao);
      const recent = deliveries.slice(0, 5);

      let html = `
        <div class="kpi-grid">
          ${this.kpi('Vật tư', UI.fmt(totalMat), 'Loại đang quản lý', 'inventory_2', 'var(--blue)')}
          ${this.kpi('Tồn kho', UI.fmt(inventory), 'Tổng số lượng', 'warehouse', 'var(--green)')}
          ${this.kpi('Thành phẩm', UI.fmt(totalProd), 'Trong kho', 'factory', 'var(--orange)')}
          ${this.kpi('Nhà cung cấp', UI.fmt(totalSup), 'Đối tác', 'business', 'var(--purple)')}
          ${this.kpi('Phiếu giao', UI.fmt(totalDel), 'Đã giao', 'local_shipping', 'var(--primary)')}
          ${this.kpi('Cảnh báo', UI.fmt(warnings.length), 'Vật tư thiếu hàng', 'warning', warnings.length > 0 ? 'var(--danger)' : 'var(--subtext)')}
        </div>
        <div style="display:flex; flex-wrap:wrap; gap:20px;">
          <div class="card card-pad" style="flex:1; min-width:280px;">
            <h3 style="font-size:17px; margin-bottom:12px;">
              <span class="material-symbol" style="vertical-align:-4px; color:var(--primary);">local_shipping</span>
              Giao hàng gần đây
            </h3>
            <hr style="border:none; border-top:1px solid var(--border); margin:8px 0;">
            ${
              recent.length === 0
                ? '<p style="color:var(--subtext); text-align:center; padding:20px;">Chưa có phiếu giao hàng nào</p>'
                : '<div class="info-list">' +
                  recent.map((d) => `
                    <div class="info-item">
                      <div class="kpi-icon" style="width:38px;height:38px;background:rgba(245,124,0,0.1);">
                        <span class="material-symbol" style="font-size:19px;color:var(--primary);">local_shipping</span>
                      </div>
                      <div style="flex:1">
                        <div style="font-weight:600;">${UI.escapeHtml(d.tenSanPham)}</div>
                        <div style="color:var(--subtext);font-size:13px;">${d.soKien} kiện → ${UI.escapeHtml(d.diaChiGiao || '')}</div>
                      </div>
                      <div style="color:var(--subtext);font-size:12px;">${UI.fmtDate(d.thoiGian)}</div>
                    </div>
                  `).join('') + '</div>'
            }
          </div>
          <div class="card card-pad" style="flex:1; min-width:280px;">
            <h3 style="font-size:17px; margin-bottom:12px;">
              <span class="material-symbol" style="vertical-align:-4px;color:${warnings.length>0?'var(--danger)':'var(--subtext)'};">warning</span>
              Cảnh báo tồn kho
              ${warnings.length > 0 ? `<span class="dashboard-badge">${warnings.length}</span>` : ''}
            </h3>
            <hr style="border:none; border-top:1px solid var(--border); margin:8px 0;">
            ${
              warnings.length === 0
                ? '<div style="text-align:center;padding:20px;"><p style="color:var(--green);">✓ Tất cả vật tư đủ tồn kho!</p></div>'
                : '<div>' +
                  warnings.slice(0, 6).map((m) => `
                    <div class="warning-item">
                      <span class="red-dot"></span>
                      <div style="flex:1; min-width:0;">
                        <div style="font-weight:600; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">${UI.escapeHtml(m.tenVatTu)}</div>
                        <div style="color:var(--danger);font-size:12px;">Tồn: ${UI.fmt(m.soLuongTon)} | Cảnh báo: ${UI.fmt(m.mucCanhBao)} ${UI.escapeHtml(m.donViTinh)}</div>
                      </div>
                    </div>
                  `).join('') + '</div>'
            }
          </div>
        </div>
      `;

      content.innerHTML = html;
      content.classList.remove('hidden');
      loading.classList.add('hidden');
    } catch (e) {
      loading.classList.add('hidden');
      content.innerHTML = '<p style="color:var(--danger);">Lỗi tải dữ liệu dashboard: ' + UI.escapeHtml(e.message || e) + '</p>';
      content.classList.remove('hidden');
    }
  },

  kpi(label, value, sub, icon, color) {
    return `
      <div class="kpi-card">
        <div class="kpi-icon" style="background:${color}1f;">
          <span class="material-symbol" style="color:${color};">${icon}</span>
        </div>
        <div>
          <div class="kpi-value" style="color:${color};">${value}</div>
          <div class="kpi-label">${label}</div>
          <div class="kpi-label" style="font-size:10px;">${sub}</div>
        </div>
      </div>
    `;
  },
};

window.DashboardView = DashboardView;


/* file: materials.js */
// =====================================================================
// Materials view (CRUD + search + import/export)
// =====================================================================

const MaterialsView = {
  _all: [],
  _filtered: [],
  _query: '',
  _debounce: null,

  async render(main) {
    main.innerHTML = `
      <div class="page-header">
        <h2>Quản lý vật tư</h2>
        <button class="btn btn-primary" id="matAdd">
          <span class="material-symbol">add</span> Thêm vật tư
        </button>
      </div>
      <div class="toolbar">
        <div class="search">
          <span class="material-symbol">search</span>
          <input type="text" id="matSearch" placeholder="Tìm theo mã, tên, nhóm, NCC...">
        </div>
        <button class="btn btn-outline" id="matRefresh">
          <span class="material-symbol">refresh</span> Làm mới
        </button>
      </div>
      <div id="matLoading" class="inline-loader"><div class="spinner"></div></div>
      <div id="matTableWrap" class="hidden"></div>
      <div id="matMobileWrap" class="hidden"></div>
      <div style="margin-top:10px; color:var(--subtext); font-size:13px;" id="matTotal"></div>
    `;

    document.getElementById('matAdd').addEventListener('click', () => this.addDialog());
    document.getElementById('matRefresh').addEventListener('click', () => this.load(true));
    document.getElementById('matSearch').addEventListener('input', (e) => {
      this._query = e.target.value;
      clearTimeout(this._debounce);
      this._debounce = setTimeout(() => this.applyFilter(), 250);
    });

    this.load();
  },

  async load(force = false) {
    const loading = document.getElementById('matLoading');
    loading.classList.remove('hidden');
    try {
      this._all = force ? await Store.refreshMaterials() : await Store.getMaterials();
      this.applyFilter();
    } catch (e) {
      UI.toast('Lỗi tải vật tư: ' + (e.message || e), 'error');
    }
    loading.classList.add('hidden');
  },

  applyFilter() {
    const q = this._query.trim().toLowerCase();
    this._filtered = q
      ? this._all.filter((m) =>
          (m.maVatTu || '').toLowerCase().includes(q) ||
          (m.tenVatTu || '').toLowerCase().includes(q) ||
          (m.nhomVatTu || '').toLowerCase().includes(q) ||
          (m.nhaCungCap || '').toLowerCase().includes(q)
        )
      : this._all;

    const isMobile = window.innerWidth < 768;
    const tableWrap = document.getElementById('matTableWrap');
    const mobileWrap = document.getElementById('matMobileWrap');
    const total = document.getElementById('matTotal');

    if (isMobile) {
      tableWrap.classList.add('hidden');
      tableWrap.innerHTML = '';
      mobileWrap.classList.remove('hidden');
      mobileWrap.innerHTML = this.mobileList();
    } else {
      mobileWrap.classList.add('hidden');
      mobileWrap.innerHTML = '';
      tableWrap.classList.remove('hidden');
      tableWrap.innerHTML = this.table();
    }
    total.textContent = `Tổng: ${this._filtered.length} vật tư`;
  },

  table() {
    if (this._filtered.length === 0) {
      return `<div class="empty-state"><span class="material-symbol">inventory_2</span><p>Không có vật tư</p></div>`;
    }
    return `
      <div class="card table-card">
        <div class="table-scroll">
          <table class="data-table">
            <thead>
              <tr>
                <th>Mã</th><th>Tên vật tư</th><th>Nhóm</th><th>ĐVT</th>
                <th>Tồn kho</th><th>Cảnh báo</th><th>Giá nhập</th><th>NCC</th><th>Thao tác</th>
              </tr>
            </thead>
            <tbody>
              ${this._filtered.map((m, i) => `
                <tr>
                  <td style="font-weight:600;color:var(--primary);">${UI.escapeHtml(m.maVatTu)}</td>
                  <td style="font-weight:600;">${UI.escapeHtml(m.tenVatTu)}</td>
                  <td>${UI.escapeHtml(m.nhomVatTu)}</td>
                  <td>${UI.escapeHtml(m.donViTinh)}</td>
                  <td style="font-weight:600;">${UI.fmt(m.soLuongTon)}</td>
                  <td style="color:${m.soLuongTon <= m.mucCanhBao ? 'var(--danger)':'var(--subtext)'};">
                    ${UI.fmt(m.mucCanhBao)}
                  </td>
                  <td>${UI.fmtMoney(m.giaNhap)}</td>
                  <td>${UI.escapeHtml(m.nhaCungCap)}</td>
                  <td>
                    <div class="table-actions">
                      <button class="icon-action import" title="Nhập kho" onclick="MaterialsView.importDialog(${i})">
                        <span class="material-symbol small">download</span>
                      </button>
                      <button class="icon-action export" title="Xuất kho" onclick="MaterialsView.exportDialog(${i})">
                        <span class="material-symbol small">upload</span>
                      </button>
                      <button class="icon-action edit" title="Sửa" onclick="MaterialsView.editDialog(${i})">
                        <span class="material-symbol small">edit</span>
                      </button>
                      <button class="icon-action delete" title="Xóa" onclick="MaterialsView.deleteItem(${i})">
                        <span class="material-symbol small">delete</span>
                      </button>
                    </div>
                  </td>
                </tr>
              `).join('')}
            </tbody>
          </table>
        </div>
      </div>
    `;
  },

  mobileList() {
    if (this._filtered.length === 0) {
      return `<div class="empty-state"><span class="material-symbol">inventory_2</span><p>Không có vật tư</p></div>`;
    }
    return this._filtered.map((m, i) => `
      <div class="list-card">
        <div class="list-title">
          <span class="material-symbol">inventory_2</span>
          <span style="flex:1;">${UI.escapeHtml(m.tenVatTu)}</span>
        </div>
        <div class="info-row"><span class="info-label">Mã:</span><span>${UI.escapeHtml(m.maVatTu)}</span></div>
        <div class="info-row"><span class="info-label">Nhóm:</span><span>${UI.escapeHtml(m.nhomVatTu)}</span></div>
        <div class="info-row"><span class="info-label">Tồn kho:</span><span style="font-weight:600;">${UI.fmt(m.soLuongTon)} ${UI.escapeHtml(m.donViTinh)}</span></div>
        <div class="info-row"><span class="info-label">Cảnh báo:</span><span>${UI.fmt(m.mucCanhBao)}</span></div>
        <div class="info-row"><span class="info-label">NCC:</span><span>${UI.escapeHtml(m.nhaCungCap)}</span></div>
        <div class="list-actions">
          <button class="btn btn-green btn-sm" onclick="MaterialsView.importDialog(${i})">Nhập</button>
          <button class="btn btn-orange btn-sm" onclick="MaterialsView.exportDialog(${i})">Xuất</button>
          <button class="btn btn-outline btn-sm" onclick="MaterialsView.editDialog(${i})">Sửa</button>
          <button class="btn btn-danger btn-sm" onclick="MaterialsView.deleteItem(${i})">Xóa</button>
        </div>
      </div>
    `).join('');
  },

  // ---- Dialogs ----
  addDialog() {
    this.formDialog(null);
  },
  editDialog(i) {
    this.formDialog(this._filtered[i]);
  },

  formDialog(material) {
    const isEdit = material != null;
    const v = (x) => material ? (material[x] ?? '') : '';

    // Build form fields
    const field = (label, id, val, type = 'text', icon) => `
      <div class="field">
        <label>${label} *</label>
        <div class="input-icon">
          <span class="material-symbol">${icon || 'edit'}</span>
          <input type="${type}" id="${id}" value="${UI.escapeHtml(val)}">
        </div>
        <span class="error-text" id="${id}_err"></span>
      </div>
    `;

    const body = document.createElement('div');
    body.innerHTML = `
      <div class="form-grid">
        <div>${field('Mã vật tư', 'm_ma', v('maVatTu'), 'text', 'qr_code')}</div>
        <div>${field('Tên vật tư', 'm_ten', v('tenVatTu'), 'text', 'inventory_2')}</div>
        <div>${field('Nhóm vật tư', 'm_nhom', v('nhomVatTu'), 'text', 'category')}</div>
        <div>${field('Đơn vị tính', 'm_donvi', v('donViTinh'), 'text', 'straighten')}</div>
        <div>${field('Số lượng tồn', 'm_ton', material ? v('soLuongTon') : '0', 'number', 'warehouse')}</div>
        <div>${field('Mức cảnh báo', 'm_canhbao', material ? v('mucCanhBao') : '0', 'number', 'warning')}</div>
        <div>${field('Giá nhập', 'm_gia', material ? v('giaNhap') : '0', 'number', 'attach_money')}</div>
        <div>${field('Nhà cung cấp', 'm_ncc', v('nhaCungCap'), 'text', 'business')}</div>
      </div>
    `;

    const footer = document.createElement('div');
    const cancel = document.createElement('button');
    cancel.className = 'btn btn-ghost';
    cancel.textContent = 'Hủy';
    cancel.onclick = () => UI.closeModal();
    const save = document.createElement('button');
    save.className = 'btn btn-primary';
    save.textContent = isEdit ? 'Cập nhật' : 'Thêm';
    save.onclick = () => this.saveForm(isEdit, material);
    footer.appendChild(cancel);
    footer.appendChild(save);

    UI.openModal({
      title: isEdit ? 'Sửa vật tư' : 'Thêm vật tư',
      body,
      footer,
      icon: 'inventory_2',
      maxWidth: 560,
    });
  },

  saveForm(isEdit, existing) {
    const get = (id) => document.getElementById(id);
    const ma = get('m_ma').value.trim();
    const ten = get('m_ten').value.trim();
    const nhom = get('m_nhom').value.trim();
    const donvi = get('m_donvi').value.trim();
    const ton = get('m_ton').value.trim();
    const canhbao = get('m_canhbao').value.trim();
    const gia = get('m_gia').value.trim();
    const ncc = get('m_ncc').value.trim();

    let ok = true;
    const setErr = (id, msg) => {
      const el = document.getElementById(id + '_err');
      if (el) { el.textContent = msg; if (msg) ok = false; }
    };
    setErr('m_ma', ma ? '' : 'Không được để trống');
    setErr('m_ten', ten ? '' : 'Không được để trống');
    setErr('m_nhom', nhom ? '' : 'Không được để trống');
    setErr('m_donvi', donvi ? '' : 'Không được để trống');
    setErr('m_ton', ton ? '' : 'Không được để trống');
    setErr('m_canhbao', canhbao ? '' : 'Không được để trống');
    setErr('m_gia', gia ? '' : 'Không được để trống');
    setErr('m_ncc', ncc ? '' : 'Không được để trống');
    if (!ok) return;

    const material = {
      id: isEdit ? existing.id : 0,
      maVatTu: ma,
      tenVatTu: ten,
      nhomVatTu: nhom,
      donViTinh: donvi,
      soLuongTon: parseInt(ton) || 0,
      mucCanhBao: parseInt(canhbao) || 0,
      giaNhap: parseFloat(gia) || 0,
      nhaCungCap: ncc,
    };

    UI.closeModal();
    (isEdit ? Store.updateMaterial(material) : Store.addMaterial(material))
      .then(() => {
        UI.toast(isEdit ? 'Đã cập nhật vật tư' : 'Đã thêm vật tư', 'success');
        this.load(true);
      })
      .catch((e) => UI.toast('Lỗi: ' + (e.message || e), 'error'));
  },

  async deleteItem(i) {
    const m = this._filtered[i];
    const ok = await UI.confirm({
      title: 'Xác nhận xóa',
      message: `Bạn có chắc muốn xóa vật tư "${m.tenVatTu}"?`,
    });
    if (!ok) return;
    try {
      await Store.deleteMaterial(m.id);
      UI.toast('Đã xóa vật tư', 'success');
      this.load(true);
    } catch (e) {
      UI.toast('Lỗi xóa: ' + (e.message || e), 'error');
    }
  },

  // ---- Import / Export ----
  importDialog(i) {
    const m = this._filtered[i];
    const body = document.createElement('div');
    body.innerHTML = `
      <div style="background:rgba(21,101,192,0.08); border-radius:10px; padding:12px; margin-bottom:14px;">
        <div style="font-weight:700;">${UI.escapeHtml(m.tenVatTu)}</div>
        <div style="color:var(--subtext); font-size:13px;">Mã: ${UI.escapeHtml(m.maVatTu)} | Tồn: ${m.soLuongTon} ${UI.escapeHtml(m.donViTinh)}</div>
      </div>
      <div class="form-grid">
        <div class="field"><label>Số lượng nhập *</label><div class="input-icon"><span class="material-symbol">add_box</span><input type="number" id="imp_sl" min="1"></div><span class="error-text" id="imp_sl_err"></span></div>
        <div class="field"><label>Đơn giá (VNĐ)</label><div class="input-icon"><span class="material-symbol">attach_money</span><input type="number" id="imp_gia" value="0"></div></div>
        <div class="field full"><label>Người nhập kho *</label><div class="input-icon"><span class="material-symbol">person</span><input type="text" id="imp_nguoi"></div><span class="error-text" id="imp_nguoi_err"></span></div>
        <div class="field full"><label>Ghi chú</label><textarea class="input-plain" id="imp_ghichu" style="width:100%;"></textarea></div>
      </div>
    `;
    const footer = document.createElement('div');
    const cancel = document.createElement('button');
    cancel.className = 'btn btn-ghost'; cancel.textContent = 'Hủy';
    cancel.onclick = () => UI.closeModal();
    const save = document.createElement('button');
    save.className = 'btn btn-blue'; save.textContent = 'Xác nhận nhập kho';
    save.onclick = () => {
      const sl = document.getElementById('imp_sl').value.trim();
      const nguoi = document.getElementById('imp_nguoi').value.trim();
      let ok = true;
      const setErr = (id, msg) => { const el = document.getElementById(id); if (el) { el.textContent = msg; if (msg) ok = false; } };
      setErr('imp_sl_err', sl && parseInt(sl) > 0 ? '' : 'Phải là số nguyên dương');
      setErr('imp_nguoi_err', nguoi ? '' : 'Không được để trống');
      if (!ok) return;
      const gia = parseFloat(document.getElementById('imp_gia').value) || 0;
      const ghichu = document.getElementById('imp_ghichu').value.trim();
      UI.closeModal();
      Store.updateMaterial({ ...m, soLuongTon: m.soLuongTon + parseInt(sl) })
        .then(() => {
          Store.addNotification({
            action: 'import',
            description: `Nhập kho ${sl} ${m.donViTinh} "${m.tenVatTu}"`,
            targetType: 'material', targetId: m.id, targetName: m.tenVatTu,
          });
          UI.toast(`Đã nhập kho ${sl} ${m.donViTinh}`, 'success');
          this.load(true);
        })
        .catch((e) => UI.toast('Lỗi: ' + (e.message || e), 'error'));
    };
    footer.appendChild(cancel); footer.appendChild(save);
    UI.openModal({ title: `Nhập kho — ${m.tenVatTu}`, body, footer, icon: 'download', maxWidth: 480 });
  },

  exportDialog(i) {
    const m = this._filtered[i];
    const body = document.createElement('div');
    body.innerHTML = `
      <div style="background:rgba(239,108,0,0.08); border-radius:10px; padding:12px; margin-bottom:14px;">
        <div style="font-weight:700;">${UI.escapeHtml(m.tenVatTu)}</div>
        <div style="color:var(--subtext); font-size:13px;">Mã: ${UI.escapeHtml(m.maVatTu)} | Tồn kho: ${m.soLuongTon} ${UI.escapeHtml(m.donViTinh)}</div>
      </div>
      <div class="form-grid">
        <div class="field full"><label>Số lượng xuất *</label><div class="input-icon"><span class="material-symbol">remove_circle</span><input type="number" id="exp_sl" min="1"></div><span class="error-text" id="exp_sl_err"></span></div>
        <div class="field"><label>Người xuất kho *</label><div class="input-icon"><span class="material-symbol">person</span><input type="text" id="exp_nguoi"></div><span class="error-text" id="exp_nguoi_err"></span></div>
        <div class="field"><label>Lý do xuất *</label><div class="input-icon"><span class="material-symbol">info</span><input type="text" id="exp_lydo"></div><span class="error-text" id="exp_lydo_err"></span></div>
        <div class="field full"><label>Ghi chú</label><textarea class="input-plain" id="exp_ghichu" style="width:100%;"></textarea></div>
      </div>
    `;
    const footer = document.createElement('div');
    const cancel = document.createElement('button');
    cancel.className = 'btn btn-ghost'; cancel.textContent = 'Hủy';
    cancel.onclick = () => UI.closeModal();
    const save = document.createElement('button');
    save.className = 'btn btn-orange'; save.textContent = 'Xác nhận xuất kho';
    save.onclick = () => {
      const sl = document.getElementById('exp_sl').value.trim();
      const nguoi = document.getElementById('exp_nguoi').value.trim();
      const lydo = document.getElementById('exp_lydo').value.trim();
      let ok = true;
      const setErr = (id, msg) => { const el = document.getElementById(id); if (el) { el.textContent = msg; if (msg) ok = false; } };
      const n = parseInt(sl);
      setErr('exp_sl_err', sl && n > 0 ? (n > m.soLuongTon ? `Vượt quá tồn kho (${m.soLuongTon})` : '') : 'Phải là số nguyên dương');
      setErr('exp_nguoi_err', nguoi ? '' : 'Không được để trống');
      setErr('exp_lydo_err', lydo ? '' : 'Không được để trống');
      if (!ok) return;
      const ghichu = document.getElementById('exp_ghichu').value.trim();
      UI.closeModal();
      Store.updateMaterial({ ...m, soLuongTon: m.soLuongTon - n })
        .then(() => {
          Store.addNotification({
            action: 'export',
            description: `Xuất kho ${n} ${m.donViTinh} "${m.tenVatTu}"`,
            targetType: 'material', targetId: m.id, targetName: m.tenVatTu,
          });
          UI.toast(`Đã xuất kho ${n} ${m.donViTinh}`, 'success');
          this.load(true);
        })
        .catch((e) => UI.toast('Lỗi: ' + (e.message || e), 'error'));
    };
    footer.appendChild(cancel); footer.appendChild(save);
    UI.openModal({ title: `Xuất kho — ${m.tenVatTu}`, body, footer, icon: 'upload', maxWidth: 480 });
  },
};

window.MaterialsView = MaterialsView;


/* file: suppliers.js */
// =====================================================================
// Suppliers view (CRUD + search + auto code)
// =====================================================================

const SuppliersView = {
  _all: [],
  _filtered: [],
  _query: '',
  _debounce: null,

  async render(main) {
    main.innerHTML = `
      <div class="page-header">
        <h2>Danh sách nhà cung cấp</h2>
        <button class="btn btn-primary" id="supAdd">
          <span class="material-symbol">add</span> Thêm NCC
        </button>
      </div>
      <div class="toolbar">
        <div class="search">
          <span class="material-symbol">search</span>
          <input type="text" id="supSearch" placeholder="Tìm theo mã, tên, SĐT...">
        </div>
        <button class="btn btn-outline" id="supRefresh">
          <span class="material-symbol">refresh</span> Làm mới
        </button>
      </div>
      <div id="supLoading" class="inline-loader"><div class="spinner"></div></div>
      <div id="supTableWrap" class="hidden"></div>
      <div id="supMobileWrap" class="hidden"></div>
      <div style="margin-top:10px; color:var(--subtext); font-size:13px;" id="supTotal"></div>
    `;

    document.getElementById('supAdd').addEventListener('click', () => this.addDialog());
    document.getElementById('supRefresh').addEventListener('click', () => this.load(true));
    document.getElementById('supSearch').addEventListener('input', (e) => {
      this._query = e.target.value;
      clearTimeout(this._debounce);
      this._debounce = setTimeout(() => this.applyFilter(), 250);
    });

    this.load();
  },

  async load(force = false) {
    const loading = document.getElementById('supLoading');
    loading.classList.remove('hidden');
    try {
      this._all = force ? await Store.refreshSuppliers() : await Store.getSuppliers();
      this.applyFilter();
    } catch (e) {
      UI.toast('Lỗi tải nhà cung cấp: ' + (e.message || e), 'error');
    }
    loading.classList.add('hidden');
  },

  applyFilter() {
    const q = this._query.trim().toLowerCase();
    this._filtered = q
      ? this._all.filter((s) =>
          (s.maNCC || '').toLowerCase().includes(q) ||
          (s.tenNCC || '').toLowerCase().includes(q) ||
          (s.soDienThoai || '').toLowerCase().includes(q) ||
          (s.nguoiLienHe || '').toLowerCase().includes(q)
        )
      : this._all;

    const isMobile = window.innerWidth < 768;
    const tableWrap = document.getElementById('supTableWrap');
    const mobileWrap = document.getElementById('supMobileWrap');
    const total = document.getElementById('supTotal');

    if (isMobile) {
      tableWrap.classList.add('hidden'); tableWrap.innerHTML = '';
      mobileWrap.classList.remove('hidden'); mobileWrap.innerHTML = this.mobileList();
    } else {
      mobileWrap.classList.add('hidden'); mobileWrap.innerHTML = '';
      tableWrap.classList.remove('hidden'); tableWrap.innerHTML = this.table();
    }
    total.textContent = `Tổng: ${this._filtered.length} nhà cung cấp`;
  },

  table() {
    if (!this._filtered.length) {
      return `<div class="empty-state"><span class="material-symbol">business</span><p>Chưa có nhà cung cấp nào</p></div>`;
    }
    return `
      <div class="card table-card">
        <div class="table-scroll">
          <table class="data-table">
            <thead><tr><th>Mã NCC</th><th>Tên nhà cung cấp</th><th>SĐT</th><th>Email</th><th>Người liên hệ</th><th>Thao tác</th></tr></thead>
            <tbody>
              ${this._filtered.map((s, i) => `
                <tr>
                  <td style="font-weight:600;color:var(--primary);">${UI.escapeHtml(s.maNCC)}</td>
                  <td style="font-weight:600;">${UI.escapeHtml(s.tenNCC)}</td>
                  <td>${UI.escapeHtml(s.soDienThoai || '—')}</td>
                  <td>${UI.escapeHtml(s.email || '—')}</td>
                  <td>${UI.escapeHtml(s.nguoiLienHe || '—')}</td>
                  <td>
                    <div class="table-actions">
                      <button class="icon-action edit" title="Sửa" onclick="SuppliersView.editDialog(${i})"><span class="material-symbol small">edit</span></button>
                      <button class="icon-action delete" title="Xóa" onclick="SuppliersView.deleteItem(${i})"><span class="material-symbol small">delete</span></button>
                    </div>
                  </td>
                </tr>
              `).join('')}
            </tbody>
          </table>
        </div>
      </div>
    `;
  },

  mobileList() {
    if (!this._filtered.length) {
      return `<div class="empty-state"><span class="material-symbol">business</span><p>Chưa có nhà cung cấp nào</p></div>`;
    }
    return this._filtered.map((s, i) => `
      <div class="list-card">
        <div class="list-title">
          <span class="material-symbol">business</span>
          <span style="flex:1;">${UI.escapeHtml(s.tenNCC)}</span>
        </div>
        <div class="info-row"><span class="info-label">Mã NCC:</span><span>${UI.escapeHtml(s.maNCC)}</span></div>
        <div class="info-row"><span class="info-label">SĐT:</span><span>${UI.escapeHtml(s.soDienThoai || '—')}</span></div>
        <div class="info-row"><span class="info-label">Email:</span><span>${UI.escapeHtml(s.email || '—')}</span></div>
        <div class="info-row"><span class="info-label">Liên hệ:</span><span>${UI.escapeHtml(s.nguoiLienHe || '—')}</span></div>
        <div class="list-actions">
          <button class="btn btn-outline btn-sm" onclick="SuppliersView.editDialog(${i})">Sửa</button>
          <button class="btn btn-danger btn-sm" onclick="SuppliersView.deleteItem(${i})">Xóa</button>
        </div>
      </div>
    `).join('');
  },

  generateCode() {
    return 'NCC' + String(this._all.length + 1).padStart(3, '0');
  },

  addDialog() {
    this.formDialog(null);
  },
  editDialog(i) {
    this.formDialog(this._filtered[i]);
  },

  formDialog(supplier) {
    const isEdit = supplier != null;
    const v = (x) => supplier ? (supplier[x] ?? '') : '';
    const field = (label, id, val, icon, type = 'text') => `
      <div class="field">
        <label>${label}${id === 'tenNCC' || id === 'maNCC' ? ' *' : ''}</label>
        <div class="input-icon"><span class="material-symbol">${icon}</span><input type="${type}" id="s_${id}" value="${UI.escapeHtml(val)}"></div>
        <span class="error-text" id="s_${id}_err"></span>
      </div>`;

    const body = document.createElement('div');
    body.innerHTML = `
      <div class="form-grid">
        <div>${field('Mã nhà cung cấp', 'maNCC', isEdit ? v('maNCC') : this.generateCode(), 'qr_code')}</div>
        <div>${field('Tên nhà cung cấp', 'tenNCC', v('tenNCC'), 'business')}</div>
        <div class="full">${field('Địa chỉ', 'diaChi', v('diaChi'), 'location_on')}</div>
        <div>${field('Số điện thoại', 'soDienThoai', v('soDienThoai'), 'phone')}</div>
        <div>${field('Email', 'email', v('email'), 'mail')}</div>
        <div class="full">${field('Người liên hệ', 'nguoiLienHe', v('nguoiLienHe'), 'person')}</div>
        <div class="full"><div class="field"><label>Ghi chú</label><textarea class="input-plain" id="s_ghiChu" style="width:100%;">${UI.escapeHtml(v('ghiChu'))}</textarea></div></div>
      </div>
    `;

    const footer = document.createElement('div');
    const cancel = document.createElement('button');
    cancel.className = 'btn btn-ghost'; cancel.textContent = 'Hủy';
    cancel.onclick = () => UI.closeModal();
    const save = document.createElement('button');
    save.className = 'btn btn-primary'; save.textContent = isEdit ? 'Cập nhật' : 'Thêm';
    save.onclick = () => this.saveForm(isEdit, supplier);
    footer.appendChild(cancel); footer.appendChild(save);

    UI.openModal({
      title: isEdit ? 'Chỉnh sửa nhà cung cấp' : 'Thêm nhà cung cấp',
      body, footer, icon: 'business', maxWidth: 560,
    });
  },

  saveForm(isEdit, existing) {
    const get = (id) => document.getElementById(id);
    const maNCC = get('s_maNCC').value.trim();
    const tenNCC = get('s_tenNCC').value.trim();
    const diaChi = get('s_diaChi').value.trim();
    const soDienThoai = get('s_soDienThoai').value.trim();
    const email = get('s_email').value.trim();
    const nguoiLienHe = get('s_nguoiLienHe').value.trim();
    const ghiChu = document.getElementById('s_ghiChu').value.trim();

    let ok = true;
    const setErr = (id, msg) => { const el = document.getElementById('s_' + id + '_err'); if (el) { el.textContent = msg; if (msg) ok = false; } };
    setErr('maNCC', maNCC ? '' : 'Không được để trống');
    setErr('tenNCC', tenNCC ? '' : 'Không được để trống');
    if (!ok) return;

    const supplier = {
      id: isEdit ? existing.id : 0,
      maNCC, tenNCC, diaChi, soDienThoai, email, nguoiLienHe, ghiChu,
      ngayTao: isEdit ? existing.ngayTao : new Date().toISOString(),
    };

    UI.closeModal();
    (isEdit ? Store.updateSupplier(supplier) : Store.addSupplier(supplier))
      .then(() => {
        UI.toast(isEdit ? 'Đã cập nhật nhà cung cấp' : 'Đã thêm nhà cung cấp', 'success');
        this.load(true);
      })
      .catch((e) => UI.toast('Lỗi: ' + (e.message || e), 'error'));
  },

  async deleteItem(i) {
    const s = this._filtered[i];
    const ok = await UI.confirm({
      title: 'Xác nhận xóa',
      message: `Bạn có chắc muốn xóa "${s.tenNCC}"?`,
    });
    if (!ok) return;
    try {
      await Store.deleteSupplier(s.id);
      UI.toast('Đã xóa nhà cung cấp', 'success');
      this.load(true);
    } catch (e) {
      UI.toast('Lỗi xóa: ' + (e.message || e), 'error');
    }
  },
};

window.SuppliersView = SuppliersView;


/* file: products.js */
// =====================================================================
// Products view (CRUD + import/export + create delivery on export)
// =====================================================================

const ProductsView = {
  _all: [],
  _filtered: [],
  _query: '',
  _debounce: null,

  async render(main) {
    main.innerHTML = `
      <div class="page-header">
        <h2>Quản lý thành phẩm</h2>
        <button class="btn btn-primary" id="prodAdd">
          <span class="material-symbol">add</span> Thêm thành phẩm
        </button>
      </div>
      <div class="toolbar">
        <div class="search">
          <span class="material-symbol">search</span>
          <input type="text" id="prodSearch" placeholder="Tìm kiếm thành phẩm...">
        </div>
        <button class="btn btn-outline" id="prodRefresh">
          <span class="material-symbol">refresh</span> Làm mới
        </button>
      </div>
      <div style="display:flex; gap:12px; margin-bottom:16px;" class="prod-stats">
        <div class="card card-pad" style="flex:1; text-align:center; background:rgba(21,101,192,0.06);">
          <div style="font-weight:700;">Tổng sản phẩm</div>
          <div style="font-size:24px; font-weight:700; color:var(--blue);" id="prodTotal">0</div>
        </div>
        <div class="card card-pad" style="flex:1; text-align:center; background:rgba(46,125,50,0.06);">
          <div style="font-weight:700;">Tổng số kiện</div>
          <div style="font-size:24px; font-weight:700; color:var(--green);" id="prodKien">0</div>
        </div>
      </div>
      <div id="prodLoading" class="inline-loader"><div class="spinner"></div></div>
      <div id="prodTableWrap" class="hidden"></div>
      <div id="prodMobileWrap" class="hidden"></div>
    `;

    document.getElementById('prodAdd').addEventListener('click', () => this.addDialog());
    document.getElementById('prodRefresh').addEventListener('click', () => this.load(true));
    document.getElementById('prodSearch').addEventListener('input', (e) => {
      this._query = e.target.value;
      clearTimeout(this._debounce);
      this._debounce = setTimeout(() => this.applyFilter(), 250);
    });

    this.load();
  },

  async load(force = false) {
    const loading = document.getElementById('prodLoading');
    loading.classList.remove('hidden');
    try {
      this._all = force ? await Store.refreshProducts() : await Store.getProducts();
      this.applyFilter();
    } catch (e) {
      UI.toast('Lỗi tải thành phẩm: ' + (e.message || e), 'error');
    }
    loading.classList.add('hidden');
  },

  applyFilter() {
    const q = this._query.trim().toLowerCase();
    this._filtered = q
      ? this._all.filter((p) =>
          (p.maSanPham || '').toLowerCase().includes(q) ||
          (p.tenSanPham || '').toLowerCase().includes(q) ||
          (p.diaChiLapRap || '').toLowerCase().includes(q)
        )
      : this._all;

    const totalProd = document.getElementById('prodTotal');
    const totalKien = document.getElementById('prodKien');
    if (totalProd) totalProd.textContent = UI.fmt(this._all.length);
    if (totalKien) totalKien.textContent = UI.fmt(this._all.reduce((s, p) => s + (p.soKien || 0), 0));

    const isMobile = window.innerWidth < 768;
    const tableWrap = document.getElementById('prodTableWrap');
    const mobileWrap = document.getElementById('prodMobileWrap');

    if (isMobile) {
      tableWrap.classList.add('hidden'); tableWrap.innerHTML = '';
      mobileWrap.classList.remove('hidden'); mobileWrap.innerHTML = this.mobileList();
    } else {
      mobileWrap.classList.add('hidden'); mobileWrap.innerHTML = '';
      tableWrap.classList.remove('hidden'); tableWrap.innerHTML = this.table();
    }
  },

  table() {
    if (!this._filtered.length) {
      return `<div class="empty-state"><span class="material-symbol">factory</span><p>Chưa có thành phẩm</p></div>`;
    }
    return `
      <div class="card table-card">
        <div class="table-scroll">
          <table class="data-table">
            <thead><tr><th>Mã</th><th>Tên sản phẩm</th><th>Đơn vị</th><th>Số kiện</th><th>Địa chỉ lắp ráp</th><th>Thao tác</th></tr></thead>
            <tbody>
              ${this._filtered.map((p, i) => `
                <tr>
                  <td style="font-weight:600;color:var(--primary);">${UI.escapeHtml(p.maSanPham)}</td>
                  <td style="font-weight:600;">${UI.escapeHtml(p.tenSanPham)}</td>
                  <td>${UI.escapeHtml(p.donVi)}</td>
                  <td style="font-weight:600;">${UI.fmt(p.soKien)}</td>
                  <td>${UI.escapeHtml(p.diaChiLapRap)}</td>
                  <td>
                    <div class="table-actions">
                      <button class="icon-action import" title="Nhập kho" onclick="ProductsView.importDialog(${i})"><span class="material-symbol small">download</span></button>
                      <button class="icon-action export" title="Xuất kho" onclick="ProductsView.exportDialog(${i})"><span class="material-symbol small">upload</span></button>
                      <button class="icon-action edit" title="Sửa" onclick="ProductsView.editDialog(${i})"><span class="material-symbol small">edit</span></button>
                      <button class="icon-action delete" title="Xóa" onclick="ProductsView.deleteItem(${i})"><span class="material-symbol small">delete</span></button>
                    </div>
                  </td>
                </tr>
              `).join('')}
            </tbody>
          </table>
        </div>
      </div>
    `;
  },

  mobileList() {
    if (!this._filtered.length) {
      return `<div class="empty-state"><span class="material-symbol">factory</span><p>Chưa có thành phẩm</p></div>`;
    }
    return this._filtered.map((p, i) => `
      <div class="list-card">
        <div class="list-title">
          <span class="material-symbol">factory</span>
          <span style="flex:1;">${UI.escapeHtml(p.tenSanPham)}</span>
        </div>
        <div class="info-row"><span class="info-label">Mã:</span><span>${UI.escapeHtml(p.maSanPham)}</span></div>
        <div class="info-row"><span class="info-label">Số kiện:</span><span style="font-weight:600;">${UI.fmt(p.soKien)} ${UI.escapeHtml(p.donVi)}</span></div>
        <div class="info-row"><span class="info-label">Địa chỉ:</span><span>${UI.escapeHtml(p.diaChiLapRap)}</span></div>
        <div class="list-actions">
          <button class="btn btn-green btn-sm" onclick="ProductsView.importDialog(${i})">Nhập</button>
          <button class="btn btn-orange btn-sm" onclick="ProductsView.exportDialog(${i})">Xuất</button>
          <button class="btn btn-outline btn-sm" onclick="ProductsView.editDialog(${i})">Sửa</button>
          <button class="btn btn-danger btn-sm" onclick="ProductsView.deleteItem(${i})">Xóa</button>
        </div>
      </div>
    `).join('');
  },

  // ---- Dialogs ----
  addDialog() { this.formDialog(null); }
  editDialog(i) { this.formDialog(this._filtered[i]); }

  formDialog(product) {
    const isEdit = product != null;
    const v = (x) => product ? (product[x] ?? '') : '';
    function field(label, id, val, icon, type) {
      if (type === undefined) type = 'text';
      return '<div class="field">' +
        '<label>' + label + ' *</label>' +
        '<div class="input-icon"><span class="material-symbol">' + icon + '</span>' +
        '<input type="' + type + '" id="p_' + id + '" value="' + UI.escapeHtml(val) + '"></div>' +
        '<span class="error-text" id="p_' + id + '_err"></span></div>';
    }

    const body = document.createElement('div');
    body.innerHTML = `
      <div class="form-grid">
        <div>${field('Mã sản phẩm', 'maSanPham', v('maSanPham'), 'qr_code')}</div>
        <div>${field('Tên sản phẩm', 'tenSanPham', v('tenSanPham'), 'inventory')}</div>
        <div>${field('Đơn vị', 'donVi', v('donVi'), 'straighten')}</div>
        <div>${field('Số kiện', 'soKien', product ? v('soKien') : '0', 'all_inbox', 'number')}</div>
        <div class="full">${field('Địa chỉ lắp ráp', 'diaChiLapRap', v('diaChiLapRap'), 'location_on')}</div>
      </div>
    `;

    const footer = document.createElement('div');
    const cancel = document.createElement('button');
    cancel.className = 'btn btn-ghost'; cancel.textContent = 'Hủy';
    cancel.onclick = () => UI.closeModal();
    const save = document.createElement('button');
    save.className = 'btn btn-primary'; save.textContent = isEdit ? 'Cập nhật' : 'Thêm';
    save.onclick = () => this.saveForm(isEdit, product);
    footer.appendChild(cancel); footer.appendChild(save);

    UI.openModal({
      title: isEdit ? 'Cập nhật thành phẩm' : 'Thêm thành phẩm',
      body, footer, icon: 'factory', maxWidth: 520,
    });
  },

  saveForm(isEdit, existing) {
    const get = (id) => document.getElementById(id);
    const maSanPham = get('p_maSanPham').value.trim();
    const tenSanPham = get('p_tenSanPham').value.trim();
    const donVi = get('p_donVi').value.trim();
    const soKien = get('p_soKien').value.trim();
    const diaChiLapRap = get('p_diaChiLapRap').value.trim();

    let ok = true;
    const setErr = (id, msg) => { const el = document.getElementById('p_' + id + '_err'); if (el) { el.textContent = msg; if (msg) ok = false; } };
    setErr('maSanPham', maSanPham ? '' : 'Không được để trống');
    setErr('tenSanPham', tenSanPham ? '' : 'Không được để trống');
    setErr('donVi', donVi ? '' : 'Không được để trống');
    setErr('soKien', soKien ? '' : 'Không được để trống');
    setErr('diaChiLapRap', diaChiLapRap ? '' : 'Không được để trống');
    if (!ok) return;

    const product = {
      id: isEdit ? existing.id : 0,
      maSanPham, tenSanPham, donVi,
      soKien: parseInt(soKien) || 0,
      diaChiLapRap,
      ngayTao: isEdit ? existing.ngayTao : new Date().toISOString(),
    };

    UI.closeModal();
    (isEdit ? Store.updateProduct(product) : Store.addProduct(product))
      .then(() => {
        UI.toast(isEdit ? 'Đã cập nhật thành phẩm' : 'Đã thêm thành phẩm', 'success');
        this.load(true);
      })
      .catch((e) => UI.toast('Lỗi: ' + (e.message || e), 'error'));
  },

  async deleteItem(i) {
    const p = this._filtered[i];
    const ok = await UI.confirm({
      title: 'Xóa thành phẩm',
      message: `Bạn có chắc muốn xóa\n${p.tenSanPham}?`,
    });
    if (!ok) return;
    try {
      await Store.deleteProduct(p.id);
      UI.toast('Đã xóa thành phẩm', 'success');
      this.load(true);
    } catch (e) {
      UI.toast('Lỗi xóa: ' + (e.message || e), 'error');
    }
  },

  // ---- Import / Export ----
  importDialog(i) {
    const p = this._filtered[i];
    const body = document.createElement('div');
    body.innerHTML = `
      <div style="background:rgba(21,101,192,0.08); border-radius:10px; padding:12px; margin-bottom:14px;">
        <div style="font-weight:700;">${UI.escapeHtml(p.tenSanPham)}</div>
        <div style="color:var(--subtext); font-size:13px;">Số kiện hiện tại: ${p.soKien} ${UI.escapeHtml(p.donVi)}</div>
      </div>
      <div class="field"><label>Số kiện nhập *</label><div class="input-icon"><span class="material-symbol">add_box</span><input type="number" id="imp_kien" min="1"></div><span class="error-text" id="imp_kien_err"></span></div>
    `;
    const footer = document.createElement('div');
    const cancel = document.createElement('button');
    cancel.className = 'btn btn-ghost'; cancel.textContent = 'Hủy';
    cancel.onclick = () => UI.closeModal();
    const save = document.createElement('button');
    save.className = 'btn btn-blue'; save.textContent = 'Lưu';
    save.onclick = () => {
      const kien = document.getElementById('imp_kien').value.trim();
      const n = parseInt(kien);
      const err = document.getElementById('imp_kien_err');
      if (!kien || n <= 0) { err.textContent = 'Số kiện phải lớn hơn 0'; return; }
      err.textContent = '';
      UI.closeModal();
      Store.updateProduct({ ...p, soKien: p.soKien + n })
        .then(() => {
          Store.addNotification({
            action: 'import', description: `Nhập kho ${n} "${p.tenSanPham}"`,
            targetType: 'product', targetId: p.id, targetName: p.tenSanPham,
          });
          UI.toast(`Đã nhập ${n} ${p.donVi}`, 'success');
          this.load(true);
        })
        .catch((e) => UI.toast('Lỗi: ' + (e.message || e), 'error'));
    };
    footer.appendChild(cancel); footer.appendChild(save);
    UI.openModal({ title: `Nhập thành phẩm: ${p.tenSanPham}`, body, footer, icon: 'download', maxWidth: 420 });
  },

  exportDialog(i) {
    const p = this._filtered[i];
    const body = document.createElement('div');
    body.innerHTML = `
      <div style="background:rgba(239,108,0,0.08); border-radius:10px; padding:12px; margin-bottom:14px;">
        <div style="font-weight:700;">${UI.escapeHtml(p.tenSanPham)}</div>
        <div style="color:var(--subtext); font-size:13px;">Số kiện hiện tại: ${p.soKien} ${UI.escapeHtml(p.donVi)}</div>
      </div>
      <div class="field"><label>Số kiện xuất *</label><div class="input-icon"><span class="material-symbol">remove_circle</span><input type="number" id="exp_kien" min="1"></div><span class="error-text" id="exp_kien_err"></span></div>
    `;
    const footer = document.createElement('div');
    const cancel = document.createElement('button');
    cancel.className = 'btn btn-ghost'; cancel.textContent = 'Hủy';
    cancel.onclick = () => UI.closeModal();
    const save = document.createElement('button');
    save.className = 'btn btn-orange'; save.textContent = 'Tiếp tục';
    save.onclick = () => {
      const kien = document.getElementById('exp_kien').value.trim();
      const n = parseInt(kien);
      const err = document.getElementById('exp_kien_err');
      if (!kien || n <= 0) { err.textContent = 'Số kiện phải lớn hơn 0'; return; }
      if (n > p.soKien) { err.textContent = 'Không đủ số kiện'; return; }
      err.textContent = '';
      UI.closeModal();
      this.deliveryDialog(p, n);
    };
    footer.appendChild(cancel); footer.appendChild(save);
    UI.openModal({ title: `Xuất thành phẩm: ${p.tenSanPham}`, body, footer, icon: 'upload', maxWidth: 420 });
  },

// Delivery dialog after export
  deliveryDialog(p, qty) {
    const body = document.createElement('div');
    function field(label, id, val, icon, required) {
      if (required === undefined) required = false;
      return '<div class="field">' +
        '<label>' + label + (required ? ' *' : '') + '</label>' +
        '<div class="input-icon"><span class="material-symbol">' + icon + '</span>' +
        '<input type="text" id="d_' + id + '" value="' + UI.escapeHtml(val) + '"></div>' +
        '<span class="error-text" id="d_' + id + '_err"></span></div>';
    }
    body.innerHTML = `
      <div class="form-grid">
        <div class="full">${field('Tên sản phẩm', 'ten', p.tenSanPham, 'inventory')}</div>
        <div class="full">${field('Số kiện', 'kien', qty, 'all_inbox')}</div>
        <div class="full">${field('Địa chỉ giao', 'diaChi', '', 'location_on', true)}</div>
        <div>${field('Người bốc hàng', 'nguoiBoc', '', 'person', true)}</div>
        <div>${field('Tài xế', 'taiXe', '', 'drive_eta', true)}</div>
        <div>${field('Biển số xe', 'bienSo', '', 'local_shipping', true)}</div>
        <div class="full"><div class="field"><label>Ghi chú</label><textarea class="input-plain" id="d_ghiChu" style="width:100%;"></textarea></div></div>
      </div>
    `;

    const footer = document.createElement('div');
    const cancel = document.createElement('button');
    cancel.className = 'btn btn-ghost'; cancel.textContent = 'Hủy';
    cancel.onclick = () => UI.closeModal();
    const save = document.createElement('button');
    save.className = 'btn btn-primary'; save.textContent = 'Xác nhận giao hàng';
    save.onclick = () => {
      const get = (id) => document.getElementById(id);
      const ten = p.tenSanPham;
      const diaChi = get('d_diaChi').value.trim();
      const nguoiBoc = get('d_nguoiBoc').value.trim();
      const taiXe = get('d_taiXe').value.trim();
      const bienSo = get('d_bienSo').value.trim();
      const ghiChu = document.getElementById('d_ghiChu').value.trim();

      let ok = true;
      const setErr = (id, msg) => { const el = document.getElementById('d_' + id + '_err'); if (el) { el.textContent = msg; if (msg) ok = false; } };
      setErr('diaChi', diaChi ? '' : 'Không được để trống');
      setErr('nguoiBoc', nguoiBoc ? '' : 'Không được để trống');
      setErr('taiXe', taiXe ? '' : 'Không được để trống');
      setErr('bienSo', bienSo ? '' : 'Không được để trống');
      if (!ok) return;

      UI.closeModal();
      // Update product stock + create delivery
      Promise.all([
        Store.updateProduct({ ...p, soKien: p.soKien - qty }),
        Store.addDelivery({
          id: 0,
          tenSanPham: ten,
          soKien: qty,
          diaChiGiao: diaChi,
          nguoiBocHang: nguoiBoc,
          taiXe,
          bienSoXe: bienSo,
          thoiGian: new Date().toISOString(),
          ghiChu,
          imagePath: null,
        }),
      ])
        .then(() => {
          Store.addNotification({
            action: 'export', description: `Xuất kho ${qty} "${p.tenSanPham}"`,
            targetType: 'product', targetId: p.id, targetName: p.tenSanPham,
          });
          UI.toast('Xuất thành phẩm thành công', 'success');
          this.load(true);
        })
        .catch((e) => UI.toast('Lỗi: ' + (e.message || e), 'error'));
    };
    footer.appendChild(cancel); footer.appendChild(save);
    UI.openModal({ title: 'Phiếu giao hàng', body, footer, icon: 'local_shipping', maxWidth: 520 });
  },
};

window.ProductsView = ProductsView;


/* file: deliveries.js */
// =====================================================================
// Delivery history view (list + search + image preview + delete)
// =====================================================================

const DeliveriesView = {
  _all: [],
  _filtered: [],
  _query: '',
  _debounce: null,

  async render(main) {
    main.innerHTML = `
      <div class="page-header">
        <h2>Lịch sử giao hàng</h2>
        <button class="btn btn-primary" id="delAdd">
          <span class="material-symbol">add</span> Tạo phiếu giao
        </button>
      </div>
      <div class="toolbar">
        <div class="search">
          <span class="material-symbol">search</span>
          <input type="text" id="delSearch" placeholder="Tìm theo sản phẩm, tài xế, biển số...">
        </div>
        <button class="btn btn-outline" id="delRefresh">
          <span class="material-symbol">refresh</span> Làm mới
        </button>
      </div>
      <div id="delLoading" class="inline-loader"><div class="spinner"></div></div>
      <div id="delWrap" class="hidden"></div>
      <div style="margin-top:12px; color:var(--subtext); font-size:13px;" id="delTotal"></div>
    `;

    document.getElementById('delAdd').addEventListener('click', () => this.addDialog());
    document.getElementById('delRefresh').addEventListener('click', () => this.load(true));
    document.getElementById('delSearch').addEventListener('input', (e) => {
      this._query = e.target.value;
      clearTimeout(this._debounce);
      this._debounce = setTimeout(() => this.applyFilter(), 250);
    });

    this.load();
  },

  async load(force = false) {
    const loading = document.getElementById('delLoading');
    loading.classList.remove('hidden');
    try {
      this._all = force ? await Store.refreshDeliveries() : await Store.getDeliveries();
      this.applyFilter();
    } catch (e) {
      UI.toast('Lỗi tải lịch sử giao hàng: ' + (e.message || e), 'error');
    }
    loading.classList.add('hidden');
  },

  applyFilter() {
    const q = this._query.trim().toLowerCase();
    this._filtered = q
      ? this._all.filter((d) =>
          (d.tenSanPham || '').toLowerCase().includes(q) ||
          (d.taiXe || '').toLowerCase().includes(q) ||
          (d.bienSoXe || '').toLowerCase().includes(q) ||
          (d.diaChiGiao || '').toLowerCase().includes(q)
        )
      : this._all;

    const wrap = document.getElementById('delWrap');
    if (!wrap) return;
    if (!this._filtered.length) {
      wrap.innerHTML = `<div class="empty-state"><span class="material-symbol">local_shipping</span><p>Chưa có phiếu giao hàng</p></div>`;
    } else {
      wrap.innerHTML = this.cards();
    }
    const total = document.getElementById('delTotal');
    if (total) total.textContent = `Tổng: ${this._filtered.length} phiếu giao`;
  },

  cards() {
    return '<div class="deliveries-grid">' + this._filtered.map((d, i) => `
      <div class="card delivery-card">
        <div style="display:flex; align-items:center; gap:10px;">
          <div class="kpi-icon" style="background:rgba(245,124,0,0.1);">
            <span class="material-symbol" style="color:var(--primary);">local_shipping</span>
          </div>
          <div style="flex:1; font-size:18px; font-weight:700;">${UI.escapeHtml(d.tenSanPham)}</div>
        </div>
        <hr class="divider">
        <div class="info-row"><span class="info-label">Số kiện:</span><span style="font-weight:600;">${UI.fmt(d.soKien)}</span></div>
        <div class="info-row"><span class="info-label">Người bốc:</span><span>${UI.escapeHtml(d.nguoiBocHang || '—')}</span></div>
        <div class="info-row"><span class="info-label">Tài xế:</span><span>${UI.escapeHtml(d.taiXe || '—')}</span></div>
        <div class="info-row"><span class="info-label">Biển số:</span><span>${UI.escapeHtml(d.bienSoXe || '—')}</span></div>
        <div class="info-row"><span class="info-label">Địa chỉ:</span><span>${UI.escapeHtml(d.diaChiGiao || '—')}</span></div>
        <div class="info-row"><span class="info-label">Thời gian:</span><span>${UI.fmtDate(d.thoiGian)}</span></div>
        ${d.ghiChu ? `<div class="info-row"><span class="info-label">Ghi chú:</span><span>${UI.escapeHtml(d.ghiChu)}</span></div>` : ''}
        ${this.imageBlock(d)}
        <div style="display:flex; justify-content:flex-end; margin-top:12px;">
          <button class="btn btn-danger btn-sm" onclick="DeliveriesView.deleteItem(${i})">
            <span class="material-symbol small">delete</span> Xóa
          </button>
        </div>
      </div>
    `).join('') + '</div>';
  },

  imageBlock(d) {
    if (!d.imagePath) return '';
    return `
      <div style="margin-top:12px;">
        <div style="font-weight:700; font-size:15px; margin-bottom:6px;">Ảnh hàng hóa</div>
        <div class="delivery-img" onclick="DeliveriesView.showImage('${UI.escapeHtml(d.imagePath)}')">
          <img src="${UI.escapeHtml(d.imagePath)}" alt="delivery photo" loading="lazy">
        </div>
      </div>
    `;
  },

  showImage(src) {
    const body = document.createElement('div');
    body.style.textAlign = 'center';
    body.innerHTML = `<img src="${src}" style="max-width:100%; max-height:70vh; border-radius:8px;">`;
    const footer = document.createElement('div');
    const close = document.createElement('button');
    close.className = 'btn btn-primary'; close.textContent = 'Đóng';
    close.onclick = () => UI.closeModal();
    footer.appendChild(close);
    UI.openModal({ title: 'Ảnh hàng hóa', body, footer, icon: 'image', maxWidth: 640 });
  },

  deleteItem(i) {
    const d = this._filtered[i];
    UI.confirm({ title: 'Xóa phiếu giao', message: `Xóa phiếu giao "${d.tenSanPham}"?` })
      .then((ok) => {
        if (!ok) return;
        Store.deleteDelivery(d.id)
          .then(() => {
            UI.toast('Đã xóa phiếu giao', 'success');
            this.load(true);
          })
          .catch((e) => UI.toast('Lỗi xóa: ' + (e.message || e), 'error'));
      });
  },

  // ---- Add delivery manually ----
  addDialog() {
    const body = document.createElement('div');
    function field(label, id, icon, required) {
      if (required === undefined) required = false;
      return '<div class="field">' +
        '<label>' + label + (required ? ' *' : '') + '</label>' +
        '<div class="input-icon"><span class="material-symbol">' + icon + '</span>' +
        '<input type="text" id="dd_' + id + '"></div>' +
        '<span class="error-text" id="dd_' + id + '_err"></span></div>';
    }
    body.innerHTML = `
      <div class="form-grid">
        <div class="full">${field('Tên sản phẩm', 'tenSanPham', 'inventory', true)}</div>
        <div class="full">${field('Số kiện', 'soKien', 'all_inbox', true)}</div>
        <div class="full">${field('Địa chỉ giao', 'diaChiGiao', 'location_on', true)}</div>
        <div>${field('Người bốc hàng', 'nguoiBocHang', 'person')}</div>
        <div>${field('Tài xế', 'taiXe', 'drive_eta')}</div>
        <div>${field('Biển số xe', 'bienSoXe', 'local_shipping')}</div>
        <div class="full"><div class="field"><label>Ghi chú</label><textarea class="input-plain" id="dd_ghiChu" style="width:100%;"></textarea></div></div>
      </div>
    `;
    const footer = document.createElement('div');
    const cancel = document.createElement('button');
    cancel.className = 'btn btn-ghost'; cancel.textContent = 'Hủy';
    cancel.onclick = () => UI.closeModal();
    const save = document.createElement('button');
    save.className = 'btn btn-primary'; save.textContent = 'Lưu phiếu giao';
    save.onclick = () => {
      const get = (id) => document.getElementById(id);
      const tenSanPham = get('dd_tenSanPham').value.trim();
      const soKien = get('dd_soKien').value.trim();
      const diaChiGiao = get('dd_diaChiGiao').value.trim();
      const nguoiBocHang = get('dd_nguoiBocHang').value.trim();
      const taiXe = get('dd_taiXe').value.trim();
      const bienSoXe = get('dd_bienSoXe').value.trim();
      const ghiChu = document.getElementById('dd_ghiChu').value.trim();

      let ok = true;
      const setErr = (id, msg) => { const el = document.getElementById('dd_' + id + '_err'); if (el) { el.textContent = msg; if (msg) ok = false; } };
      setErr('tenSanPham', tenSanPham ? '' : 'Không được để trống');
      setErr('soKien', soKien ? '' : 'Không được để trống');
      setErr('diaChiGiao', diaChiGiao ? '' : 'Không được để trống');
      if (!ok) return;

      UI.closeModal();
      Store.addDelivery({
        id: 0,
        tenSanPham,
        soKien: parseInt(soKien) || 0,
        diaChiGiao,
        nguoiBocHang,
        taiXe,
        bienSoXe,
        thoiGian: new Date().toISOString(),
        ghiChu,
        imagePath: null,
      })
        .then(() => {
          Store.addNotification({
            action: 'deliver', description: `Tạo phiếu giao: ${tenSanPham} (${soKien} kiện)`,
            targetType: 'delivery', targetId: 'new', targetName: tenSanPham,
          });
          UI.toast('Đã tạo phiếu giao', 'success');
          this.load(true);
        })
        .catch((e) => UI.toast('Lỗi: ' + (e.message || e), 'error'));
    };
    footer.appendChild(cancel); footer.appendChild(save);
    UI.openModal({ title: 'Tạo phiếu giao', body, footer, icon: 'local_shipping', maxWidth: 520 });
  },
};

window.DeliveriesView = DeliveriesView;


/* file: reports.js */
// =====================================================================
// Reports view (KPI cards + 3 tabs: Nhập kho, Xuất kho, Cảnh báo)
// =====================================================================

const ReportsView = {
  _tab: 0,
  _data: { totalMaterial: 0, totalInventory: 0, warningCount: 0, totalProduct: 0, totalDelivery: 0, totalSupplier: 0 },
  _warnings: [],

  async render(main) {
    main.innerHTML = `
      <div class="page-header"><h2>Báo cáo & Thống kê</h2></div>
      <div id="repLoading" class="inline-loader"><div class="spinner"></div></div>
      <div id="repContent" class="hidden"></div>
    `;
    this.load();
  },

  async load() {
    const loading = document.getElementById('repLoading');
    const content = document.getElementById('repContent');
    loading.classList.remove('hidden');
    content.classList.add('hidden');
    try {
      const results = await Promise.all([
        Store.countMaterials(),
        Store.getMaterials(),
        Store.countProducts(),
        Store.countDeliveries(),
        Store.countSuppliers(),
      ]);
      const totalMat = results[0];
      const materials = results[1];
      const warnings = materials.filter((m) => m.soLuongTon <= m.mucCanhBao);
      this._data = {
        totalMaterial: totalMat,
        totalInventory: materials.reduce((s, m) => s + m.soLuongTon, 0),
        warningCount: warnings.length,
        totalProduct: results[2],
        totalDelivery: results[3],
        totalSupplier: results[4],
      };
      this._warnings = warnings;
      this._tab = 0;
      this.renderContent(content);
      loading.classList.add('hidden');
      content.classList.remove('hidden');
    } catch (e) {
      loading.classList.add('hidden');
      content.innerHTML = '<p style="color:var(--danger);">Lỗi tải báo cáo: ' + UI.escapeHtml(e.message || e) + '</p>';
      content.classList.remove('hidden');
    }
  },

  kpi(label, value, icon, color) {
    return `
      <div class="kpi-card report-kpi">
        <div class="kpi-icon" style="background:${color}1f;">
          <span class="material-symbol" style="color:${color};">${icon}</span>
        </div>
        <div>
          <div class="kpi-value" style="color:${color};">${UI.fmt(value)}</div>
          <div class="kpi-label">${label}</div>
        </div>
      </div>
    `;
  },

  renderContent(content) {
    const d = this._data;
    const tabs = [
      { id: 0, label: 'Nhập kho', icon: 'input' },
      { id: 1, label: 'Xuất kho', icon: 'output' },
      { id: 2, label: 'Cảnh báo', icon: 'warning_amber' },
    ];
    content.innerHTML = `
      <div class="kpi-grid">
        ${this.kpi('Loại vật tư', d.totalMaterial, 'inventory_2', 'var(--blue)')}
        ${this.kpi('Tổng tồn kho', d.totalInventory, 'warehouse', 'var(--green)')}
        ${this.kpi('Cảnh báo thiếu', d.warningCount, 'warning_amber', d.warningCount > 0 ? 'var(--danger)' : 'var(--subtext)')}
        ${this.kpi('Thành phẩm', d.totalProduct, 'factory', 'var(--orange)')}
        ${this.kpi('Phiếu giao', d.totalDelivery, 'local_shipping', 'var(--purple)')}
        ${this.kpi('Nhà cung cấp', d.totalSupplier, 'business', 'var(--primary)')}
      </div>
      <div class="tabs">
        ${tabs.map((t) => `
          <button class="tab-btn ${t.id === this._tab ? 'active' : ''}" onclick="ReportsView.switchTab(${t.id})">
            <span class="material-symbol">${t.icon}</span> ${t.label}
          </button>
        `).join('')}
      </div>
      <div id="repTabContent" style="margin-top:16px;">${this.tabContent()}</div>
    `;
  },

  switchTab(i) {
    this._tab = i;
    const content = document.getElementById('repContent');
    if (content) this.renderContent(content);
  },

  tabContent() {
    if (this._tab === 2) return this.warningContent();
    return this.emptyTab(this._tab === 0 ? 'Chưa có lịch sử nhập kho' : 'Chưa có lịch sử xuất kho');
  },

  emptyTab(msg) {
    return `<div class="empty-state"><span class="material-symbol">inbox</span><p>${msg}</p></div>`;
  },

  warningContent() {
    if (!this._warnings.length) {
      return `
        <div class="card" style="text-align:center; padding:30px;">
          <span class="material-symbol" style="font-size:60px; color:var(--green);">check_circle</span>
          <p style="color:var(--green); font-size:16px;">Tất cả vật tư đều đủ tồn kho!</p>
        </div>
      `;
    }
    return `
      <div class="card table-card">
        <div class="table-scroll">
          <table class="data-table">
            <thead><tr><th>Vật tư</th><th>Mã</th><th>Tồn kho</th><th>Mức cảnh báo</th><th>Mức độ</th></tr></thead>
            <tbody>
              ${this._warnings.map((m) => {
                const pct = m.mucCanhBao > 0 ? Math.min(m.soLuongTon / m.mucCanhBao, 1) : 0;
                return `
                  <tr>
                    <td style="font-weight:600;">${UI.escapeHtml(m.tenVatTu)}</td>
                    <td>${UI.escapeHtml(m.maVatTu)}</td>
                    <td style="color:var(--danger); font-weight:700;">${UI.fmt(m.soLuongTon)} ${UI.escapeHtml(m.donViTinh)}</td>
                    <td>${UI.fmt(m.mucCanhBao)}</td>
                    <td><div class="progress-bar"><div class="progress-fill" style="width:${(pct * 100).toFixed(0)}%;"></div></div></td>
                  </tr>
                `;
              }).join('')}
            </tbody>
          </table>
        </div>
      </div>
    `;
  },
};

window.ReportsView = ReportsView;


/* file: notifications.js */
// =====================================================================
// Notifications view (realtime list + refresh)
// =====================================================================

const NotificationsView = {
  _unsub: null,

  async render(main) {
    main.innerHTML = `
      <div class="page-header">
        <h2>Thông báo</h2>
        <button class="btn btn-outline" id="notifRefresh">
          <span class="material-symbol">refresh</span> Làm mới
        </button>
      </div>
      <div class="notif-toggle">
        <label class="switch-label">
          <span class="material-symbol">sensors</span> Theo dõi thời gian thực
          <input type="checkbox" id="notifRealtime" checked>
          <span class="switch"></span>
        </label>
      </div>
      <div id="notifLoading" class="inline-loader"><div class="spinner"></div></div>
      <div id="notifWrap" class="hidden"></div>
    `;

    this._unsub?.();
    // Real-time subscription
    this._unsub = Store.streamNotifications((list) => {
      if (document.getElementById('notifRealtime')) {
        this.fill(list);
      }
    });

    document.getElementById('notifRefresh').addEventListener('click', () => this.load());
    document.getElementById('notifRealtime').addEventListener('change', (e) => {
      if (e.target.checked) {
        this._unsub?.();
        this._unsub = Store.streamNotifications((list) => this.fill(list));
      } else {
        this._unsub?.();
      }
    });

    this.load();
  },

  async load() {
    const loading = document.getElementById('notifLoading');
    const wrap = document.getElementById('notifWrap');
    loading.classList.remove('hidden');
    try {
      const list = await Store.getNotifications();
      this.fill(list);
    } catch (e) {
      wrap.innerHTML = `<p style="color:var(--danger);">Lỗi tải thông báo: ${UI.escapeHtml(e.message || e)}</p>`;
      wrap.classList.remove('hidden');
    }
    loading.classList.add('hidden');
  },

destroy() {
    this._unsub?.();
    this._unsub = null;
  },

  // Panel (bell) toggle/hide — used by App.bindShellEvents
  toggle() {
    const panel = document.getElementById('notifPanel');
    if (!panel) return;
    if (panel.classList.contains('hidden')) {
      // render into panel
      const listEl = document.getElementById('notifList');
      if (listEl) {
        this._panelEl = listEl;
        this.loadPanel();
      }
      panel.classList.remove('hidden');
    } else {
      panel.classList.add('hidden');
    }
  },

  hide() {
    const panel = document.getElementById('notifPanel');
    if (panel) panel.classList.add('hidden');
  },

  async loadPanel() {
    try {
      const list = await Store.getNotifications(20);
      const listEl = document.getElementById('notifList');
      if (!listEl) return;
      if (!list.length) {
        listEl.innerHTML = `<div style="padding:20px; text-align:center; color:var(--subtext);">Chưa có thông báo</div>`;
      } else {
        listEl.innerHTML = list.map((n) => `
          <div class="notif-item ${n.action || ''}" style="padding:10px 14px; border-bottom:1px solid var(--border);">
            <div style="font-size:13px;">${UI.escapeHtml(n.description)}</div>
            <div style="color:var(--subtext); font-size:11px;">${UI.escapeHtml(n.displayName || n.userName || '')} — ${UI.timeAgo(n.timestamp)}</div>
          </div>
        `).join('');
      }
    } catch (e) {
      const listEl = document.getElementById('notifList');
      if (listEl) listEl.innerHTML = `<div style="padding:20px; text-align:center; color:var(--subtext);">Lỗi tải</div>`;
    }
  },

  fill(list) {
    const loading = document.getElementById('notifLoading');
    const wrap = document.getElementById('notifWrap');
    if (!wrap) return;
    if (loading) loading.classList.add('hidden');

    if (!list.length) {
      wrap.innerHTML = `<div class="empty-state"><span class="material-symbol">notifications</span><p>Chưa có thông báo nào</p></div>`;
    } else {
      wrap.innerHTML = '<div class="notif-list">' + list.map((n) => `
        <div class="notif-item ${n.action || ''}">
          <div class="kpi-icon notif-icon">
            <span class="material-symbol">${this.iconFor(n.action)}</span>
          </div>
          <div style="flex:1; min-width:0;">
            <div style="font-weight:600;">${UI.escapeHtml(n.description)}</div>
            <div style="color:var(--subtext); font-size:12px;">
              ${UI.escapeHtml(n.displayName || n.userName || '')} (${UI.escapeHtml(n.userRole || '')}) — ${UI.fmtDate(n.timestamp)}
            </div>
          </div>
        </div>
      `).join('') + '</div>';
    }
    wrap.classList.remove('hidden');
  },

  iconFor(action) {
    switch (action) {
      case 'add': return 'add_circle';
      case 'update': return 'edit';
      case 'delete': return 'delete';
      case 'import': return 'download';
      case 'export': return 'upload';
      case 'deliver': return 'local_shipping';
      default: return 'notifications';
    }
  },
};

window.NotificationsView = NotificationsView;

