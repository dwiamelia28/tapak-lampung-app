// Memberi custom claim admin ke satu akun. Jalankan SEKALI dari komputer Anda.
// Pemakaian:  node scripts/set_admin.js email-admin@contoh.com
// Prasyarat:  npm i firebase-admin  dan  scripts/serviceAccountKey.json
//             (Firebase Console > Project settings > Service accounts > Generate new private key)
// JANGAN commit serviceAccountKey.json (sudah ada di .gitignore).
const admin = require('firebase-admin');
admin.initializeApp({ credential: admin.credential.cert(require('./serviceAccountKey.json')) });

const email = process.argv[2];
if (!email) { console.error('Berikan email akun.'); process.exit(1); }

admin.auth().getUserByEmail(email)
  .then((u) => admin.auth().setCustomUserClaims(u.uid, { admin: true }).then(() => u))
  .then((u) => { console.log(`OK: ${u.email} sekarang admin. Login ulang di aplikasi.`); process.exit(0); })
  .catch((e) => { console.error(e.message); process.exit(1); });
