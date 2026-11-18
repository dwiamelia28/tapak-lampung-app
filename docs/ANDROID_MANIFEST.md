# Pengaturan Android (wajib, sekali saja)

Buka `android/app/src/main/AndroidManifest.xml`.

## 1. Izin (di dalam `<manifest ...>`, di atas `<application>`)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

## 2. Di dalam `<application ...>` (sejajar dengan `<activity>`)

Channel FCM bawaan, agar push notification muncul sebagai pop-up saat aplikasi di background:
```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="tapak_high" />
```

Penerima notifikasi TERJADWAL (pengingat kunjungan dan pengingat belajar). Tanpa dua blok ini,
notifikasi terjadwal tidak akan tampil dan hilang setelah HP dinyalakan ulang:
```xml
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
        <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
    </intent-filter>
</receiver>
```

## 3. Jalankan ulang penuh
```
flutter pub get
flutter run
```
