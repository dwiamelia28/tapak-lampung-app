// Memuat data awal 4 bab ke Firestore. Jalankan SEKALI dari komputer Anda:
//   cd scripts && npm init -y && npm i firebase-admin && node seed_data.js
// Prasyarat: scripts/serviceAccountKey.json (Firebase Console > Project settings >
// Service accounts > Generate new private key). Jangan di-commit.
// SEMUA konten bertanda verified:false karena BELUM diverifikasi sumber resmi.
const admin = require('firebase-admin');
admin.initializeApp({ credential: admin.credential.cert(require('./serviceAccountKey.json')) });
const db = admin.firestore();
const now = admin.firestore.FieldValue.serverTimestamp();

const q = (id, text, options, correctIndex, explanation) => ({ id, text, options, correctIndex, explanation });
const hs = (id, label, description, dx, dy) => ({ id, label, description, dx, dy });
const NOTE = ' (Data awal, perlu validasi.)';

const chapters = [
  {
    id: 'chapter_1', order: 1, theme: 'rumah', title: 'Rumah Adat Lampung',
    description: 'Kenali Nuwo Sesat, balai adat berbentuk rumah panggung.',
    isLockedByDefault: false,
    content: {
      title: 'Nuwo Sesat',
      body:
        'Selamat datang di Lampung! Perjalananmu dimulai dari sebuah rumah adat bernama Nuwo Sesat.\n\n' +
        'Dalam bahasa Lampung, "nuwo" berarti rumah. Nuwo Sesat dikenal sebagai balai adat, tempat masyarakat adat berkumpul untuk bermusyawarah dan menggelar acara adat.\n\n' +
        'Bentuknya berupa rumah panggung dari kayu: bangunan diangkat dari tanah oleh tiang-tiang penyangga, dan untuk naik ke dalamnya digunakan tangga.\n\n' +
        'Ketuk titik-titik bercahaya pada gambar untuk mengenal bagian-bagiannya.',
      keyFacts: [
        'Nuwo Sesat adalah rumah adat Lampung berbentuk rumah panggung.',
        'Fungsinya dikenal sebagai balai adat untuk musyawarah dan acara adat.',
        'Bangunan ini terutama dibuat dari kayu.',
      ],
      hotspots: [
        hs('atap', 'Atap', 'Bagian paling atas bangunan yang melindungi ruang di bawahnya. Pada ilustrasi ini atapnya digambarkan bertingkat.', 0.5, 0.24),
        hs('balai', 'Ruang balai', 'Ruang utama tempat pertemuan adat dilakukan.' + NOTE, 0.5, 0.52),
        hs('tiang', 'Tiang penyangga', 'Tiang kayu yang mengangkat bangunan dari tanah, ciri khas rumah panggung.', 0.28, 0.74),
        hs('tangga', 'Tangga', 'Jalan naik menuju lantai bangunan.', 0.82, 0.76),
      ],
    },
    challenge: {
      type: 'find', title: 'Temukan Bagian Rumah Adat',
      instruction: 'Ketuk bagian rumah adat sesuai perintah pada gambar!',
      findIds: ['tiang', 'atap', 'tangga', 'balai'],
    },
    quiz: {
      title: 'Kuis Rumah Adat Lampung', passingScore: 60,
      questions: [
        q('q1', 'Nuwo Sesat adalah rumah adat dari daerah mana?', ['Lampung', 'Aceh', 'Bali', 'Papua'], 0, 'Nuwo Sesat berasal dari Lampung.'),
        q('q2', 'Dalam bahasa Lampung, "nuwo" berarti ...', ['Rumah', 'Sungai', 'Kain', 'Tarian'], 0, '"Nuwo" berarti rumah.'),
        q('q3', 'Bentuk Nuwo Sesat termasuk jenis ...', ['Rumah panggung', 'Rumah susun', 'Rumah tenda', 'Rumah kaca'], 0, 'Nuwo Sesat berbentuk rumah panggung.'),
        q('q4', 'Bagian yang mengangkat bangunan dari tanah disebut ...', ['Tiang penyangga', 'Jendela', 'Atap', 'Pagar'], 0, 'Tiang penyangga mengangkat bangunan dari tanah.'),
        q('q5', 'Nuwo Sesat dikenal sebagai tempat untuk ...', ['Musyawarah dan acara adat', 'Menjual hasil bumi', 'Menyimpan perahu', 'Menanam padi'], 0, 'Nuwo Sesat dikenal sebagai balai adat.'),
      ],
    },
  },
  {
    id: 'chapter_2', order: 2, theme: 'kain', title: 'Kain dan Busana Tradisional',
    description: 'Mengenal kain Tapis dan siger, mahkota emas Lampung.',
    isLockedByDefault: true,
    content: {
      title: 'Kain Tapis dan Siger',
      body:
        'Perjalananmu berlanjut ke dunia kain! Lampung dikenal dengan kain Tapis, kain tenun yang dihias sulaman benang berwarna keemasan.\n\n' +
        'Motif pada kain tradisional Lampung beragam. Salah satunya motif kapal, yang sering dikenali pada kain tradisional Lampung.\n\n' +
        'Busana adat Lampung juga dilengkapi siger, mahkota berwarna emas yang menjadi salah satu ikon budaya Lampung.\n\n' +
        'Ketuk bagian-bagian pada gambar untuk mengenalnya.',
      keyFacts: [
        'Tapis adalah kain tenun tradisional Lampung dengan sulaman benang keemasan.',
        'Siger adalah mahkota emas yang menjadi ikon budaya Lampung.',
        'Motif kapal dikenal pada kain tradisional Lampung.',
      ],
      hotspots: [
        hs('sulaman', 'Sulaman benang emas', 'Hiasan benang berwarna keemasan yang menjadi ciri kain Tapis.', 0.14, 0.5),
        hs('motif', 'Motif kapal', 'Salah satu motif yang dikenal pada kain tradisional Lampung.' + NOTE, 0.39, 0.45),
        hs('kain', 'Kain Tapis', 'Kain tenun tradisional Lampung.', 0.39, 0.78),
        hs('siger', 'Siger', 'Mahkota emas dalam busana adat Lampung, juga dikenal sebagai ikon Lampung.', 0.84, 0.36),
      ],
    },
    challenge: {
      type: 'match', title: 'Pasangkan Busana dan Maknanya',
      instruction: 'Seret kartu keterangan ke nama yang sesuai!',
      targets: [
        { id: 'tapis', label: 'Kain Tapis', icon: 'checkroom' },
        { id: 'siger', label: 'Siger', icon: 'crown' },
        { id: 'kapal', label: 'Motif Kapal', icon: 'ship' },
      ],
      tokens: [
        { id: 't1', label: 'Kain tenun bersulam benang keemasan', target: 'tapis' },
        { id: 't2', label: 'Mahkota emas ikon Lampung', target: 'siger' },
        { id: 't3', label: 'Motif bergambar kapal', target: 'kapal' },
      ],
    },
    quiz: {
      title: 'Kuis Kain dan Busana', passingScore: 60,
      questions: [
        q('q1', 'Kain tenun khas Lampung dengan sulaman benang keemasan disebut ...', ['Tapis', 'Ulos', 'Songket Palembang', 'Tenun Ikat Sumba'], 0, 'Kain tenun Lampung itu bernama Tapis.'),
        q('q2', 'Mahkota emas ikon budaya Lampung disebut ...', ['Siger', 'Blangkon', 'Udeng', 'Kopiah'], 0, 'Siger adalah mahkota emas Lampung.'),
        q('q3', 'Kain Tapis dibuat dengan teknik ...', ['Tenun dan sulam', 'Cetak digital', 'Rajut mesin', 'Lukis cat air'], 0, 'Tapis berupa kain tenun yang disulam.'),
        q('q4', 'Kain Tapis berasal dari provinsi ...', ['Lampung', 'Bali', 'Maluku', 'Kalimantan Utara'], 0, 'Tapis berasal dari Lampung.'),
        q('q5', 'Salah satu motif yang dikenal pada kain tradisional Lampung adalah motif ...', ['Kapal', 'Roket', 'Komputer', 'Mobil'], 0, 'Motif kapal dikenal pada kain tradisional Lampung.'),
      ],
    },
  },
  {
    id: 'chapter_3', order: 3, theme: 'seni', title: 'Seni dan Pertunjukan',
    description: 'Tarian dan alat musik tradisional Lampung.',
    isLockedByDefault: true,
    content: {
      title: 'Tari dan Musik Lampung',
      body:
        'Sekarang saatnya menikmati seni! Lampung punya beragam tarian tradisional, misalnya Tari Sigeh Pengunten yang dikenal sebagai tarian penyambutan tamu, dan Tari Bedana.\n\n' +
        'Ada juga gamolan, alat musik berbilah bambu yang dimainkan dengan cara dipukul.\n\n' +
        'Ketuk penari dan alat musik pada gambar untuk mengenalnya.',
      keyFacts: [
        'Sigeh Pengunten dikenal sebagai tarian penyambutan tamu.',
        'Bedana adalah salah satu tarian tradisional Lampung.',
        'Gamolan adalah alat musik berbilah bambu yang dipukul.',
      ],
      hotspots: [
        hs('penari', 'Penari', 'Tarian tradisional Lampung antara lain Sigeh Pengunten (penyambutan tamu) dan Bedana.' + NOTE, 0.27, 0.55),
        hs('siger', 'Siger penari', 'Penari kerap mengenakan siger sebagai hiasan kepala.' + NOTE, 0.27, 0.15),
        hs('gamolan', 'Gamolan', 'Alat musik berbilah bambu yang dimainkan dengan cara dipukul.', 0.72, 0.5),
      ],
    },
    challenge: {
      type: 'match', title: 'Kelompokkan Seni Lampung',
      instruction: 'Seret setiap kartu ke kelompok yang tepat: Tarian atau Alat Musik!',
      targets: [
        { id: 'tari', label: 'Tarian', icon: 'dance' },
        { id: 'musik', label: 'Alat Musik', icon: 'music' },
      ],
      tokens: [
        { id: 't1', label: 'Sigeh Pengunten', target: 'tari' },
        { id: 't2', label: 'Bedana', target: 'tari' },
        { id: 't3', label: 'Gamolan', target: 'musik' },
        { id: 't4', label: 'Melinting', target: 'tari' },
      ],
    },
    quiz: {
      title: 'Kuis Seni dan Pertunjukan', passingScore: 60,
      questions: [
        q('q1', 'Tarian penyambutan tamu yang dikenal dari Lampung adalah ...', ['Sigeh Pengunten', 'Kecak', 'Saman', 'Jaipong'], 0, 'Sigeh Pengunten dikenal sebagai tarian penyambutan tamu.'),
        q('q2', 'Bilah gamolan terbuat dari ...', ['Bambu', 'Kaca', 'Plastik', 'Besi'], 0, 'Gamolan berbilah bambu.'),
        q('q3', 'Gamolan dimainkan dengan cara ...', ['Dipukul', 'Ditiup', 'Dipetik', 'Digesek'], 0, 'Gamolan dimainkan dengan dipukul.'),
        q('q4', 'Tari Bedana berasal dari ...', ['Lampung', 'Bali', 'Papua', 'Sulawesi Utara'], 0, 'Bedana adalah tarian tradisional Lampung.'),
        q('q5', 'Hiasan kepala emas yang dikenal dalam busana adat Lampung disebut ...', ['Siger', 'Udeng', 'Peci', 'Kuluk'], 0, 'Siger adalah mahkota emas Lampung.'),
      ],
    },
  },
  {
    id: 'chapter_4', order: 4, theme: 'kuliner', title: 'Kuliner Tradisional Lampung',
    description: 'Seruit, kopi robusta, dan engkak.',
    isLockedByDefault: true,
    content: {
      title: 'Cita Rasa Lampung',
      body:
        'Petualanganmu ditutup dengan cita rasa! Salah satu hidangan yang dikenal adalah seruit, sambal khas Lampung yang biasa dinikmati bersama ikan dan lalapan.\n\n' +
        'Lampung juga dikenal sebagai penghasil kopi robusta, dan punya kue ketan manis bernama engkak.\n\n' +
        'Ketuk makanan pada gambar untuk mengenalnya.',
      keyFacts: [
        'Seruit adalah sambal khas Lampung yang biasa dimakan dengan ikan dan lalapan.',
        'Lampung dikenal sebagai penghasil kopi robusta.',
        'Engkak adalah kue ketan manis tradisional.',
      ],
      hotspots: [
        hs('seruit', 'Seruit', 'Sambal khas Lampung yang biasa disantap bersama ikan dan lalapan.' + NOTE, 0.54, 0.62),
        hs('kopi', 'Kopi Lampung', 'Lampung dikenal sebagai penghasil kopi, terutama jenis robusta.', 0.8, 0.55),
        hs('engkak', 'Engkak', 'Kue ketan manis tradisional.' + NOTE, 0.66, 0.85),
        hs('lauk', 'Nasi dan ikan', 'Seruit biasanya disantap bersama nasi dan ikan.' + NOTE, 0.28, 0.66),
      ],
    },
    challenge: {
      type: 'find', title: 'Temukan Hidangan Lampung',
      instruction: 'Ketuk hidangan sesuai perintah pada gambar!',
      findIds: ['kopi', 'seruit', 'engkak'],
    },
    quiz: {
      title: 'Kuis Kuliner Lampung', passingScore: 60,
      questions: [
        q('q1', 'Sambal khas Lampung yang dimakan bersama ikan dan lalapan disebut ...', ['Seruit', 'Sambal matah', 'Dabu-dabu', 'Colo-colo'], 0, 'Seruit adalah sambal khas Lampung.'),
        q('q2', 'Lampung dikenal sebagai penghasil ...', ['Kopi robusta', 'Kurma', 'Zaitun', 'Gandum'], 0, 'Lampung dikenal sebagai penghasil kopi robusta.'),
        q('q3', 'Kue ketan manis tradisional Lampung adalah ...', ['Engkak', 'Pia', 'Bika Ambon', 'Dodol Garut'], 0, 'Engkak adalah kue ketan manis tradisional Lampung.'),
        q('q4', 'Seruit biasanya disantap bersama ...', ['Ikan', 'Es krim', 'Roti tawar', 'Cokelat'], 0, 'Seruit biasa dimakan dengan ikan dan lalapan.'),
        q('q5', 'Engkak termasuk jenis ...', ['Kue manis', 'Minuman dingin', 'Sayuran mentah', 'Sup asin'], 0, 'Engkak adalah kue ketan yang manis.'),
      ],
    },
  },
];

async function main() {
  const batch = db.batch();
  for (const c of chapters) {
    batch.set(db.collection('chapters').doc(c.id), {
      title: c.title, description: c.description, order: c.order, theme: c.theme,
      isPublished: true, isLockedByDefault: c.isLockedByDefault, verified: false,
      coverImageUrl: null, createdAt: now, updatedAt: now,
    });
    batch.set(db.collection('cultural_contents').doc(`content_${c.id}`), {
      chapterId: c.id, title: c.content.title, description: c.description, body: c.content.body,
      keyFacts: c.content.keyFacts, imageUrl: null, interactiveObjects: c.content.hotspots,
      order: 1, verified: false, createdAt: now, updatedAt: now,
    });
    batch.set(db.collection('quizzes').doc(`quiz_${c.id}`), {
      chapterId: c.id, title: c.quiz.title, passingScore: c.quiz.passingScore,
      questions: c.quiz.questions, isPublished: true, verified: false, createdAt: now, updatedAt: now,
    });
    batch.set(db.collection('challenges').doc(`challenge_${c.id}`), {
      chapterId: c.id, ...c.challenge, isPublished: true, verified: false, createdAt: now, updatedAt: now,
    });
  }
  await batch.commit();
  console.log('Selesai: 4 bab, materi, kuis, dan tantangan dimuat (verified:false).');
}
main().then(() => process.exit(0)).catch((e) => { console.error(e); process.exit(1); });
