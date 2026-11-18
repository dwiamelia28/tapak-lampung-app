
class CulturePhoto {
  const CulturePhoto({
    required this.id,
    required this.asset,
    required this.title,
    this.credit = '',
  });

  final String id;
  final String asset;
  final String title;
  final String credit;
}

class CulturePhotos {
  CulturePhotos._();

  static const nuwoSesat = CulturePhoto(
    id: 'nuwo_sesat',
    asset: 'assets/images/rumahadat.jpg',
    title: 'Rumah Adat Nuwo Sesat',
  );

  static const kainTapis = CulturePhoto(
    id: 'kain_tapis',
    asset: 'assets/images/kain tapis.jpg',
    title: 'Kain Tapis Lampung',
  );

  static const siger = CulturePhoto(
    id: 'siger',
    asset: 'assets/images/baju adat.jpeg',
    title: 'Siger dan Busana Adat Lampung',
  );

  static const tari = CulturePhoto(
    id: 'tari_lampung',
    asset: 'assets/images/tari.jpg',
    title: 'Tari Tradisional Lampung',
  );

  static const gamolan = CulturePhoto(
    id: 'gamolan',
    asset: 'assets/photos/gamolan.jpg',
    title: 'Gamolan, Alat Musik Bambu',
  );

  static const kuliner = CulturePhoto(
    id: 'kuliner_lampung',
    asset: 'assets/images/kuliner_lampung.jpeg',
    title: 'Kuliner Khas Lampung',
  );

  static const hero = <CulturePhoto>[
    nuwoSesat,
    kainTapis,
    siger,
    tari,
    kuliner,
  ];

  static CulturePhoto forTheme(String theme) {
    switch (theme) {
      case 'kain':
        return kainTapis;
      case 'seni':
        return tari;
      case 'kuliner':
        return kuliner;
      default:
        return nuwoSesat;
    }
  }
}
