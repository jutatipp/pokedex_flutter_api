# PPokedex App (Flutter)

โปรเจกต์นี้เป็นแอปพลิเคชัน **Pokedex** พัฒนาด้วย Flutter  
ใช้ **PokeAPI** สำหรับดึงข้อมูล Pokémon มาแสดงผลในแอป

## การทำงานของแอป

- หน้าแรกจะแสดง **รายชื่อ Pokemon**
- สามารถสลับการแสดงผลได้ระหว่าง **List View** และ **Grid View**
- เลื่อนหน้าจอลงเพื่อโหลด Pokemon เพิ่ม (Load more)
- เมื่อกดที่ Pokemon แต่ละตัว จะไปยัง **หน้ารายละเอียด**

## หน้ารายละเอียด Pokemon

- แสดงรูป Pokémon ขนาดใหญ่
- แสดงประเภท (Type)
- แสดงค่าสถานะ (Stats) ของ Pokémon

## Run
- flutter pub get
- flutter run -d chrome

เป็นงานเพื่อฝึกการใช้งาน API และการแสดงผลข้อมูลใน Flutter
