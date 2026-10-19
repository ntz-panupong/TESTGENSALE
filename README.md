# Coverage - LME Price | SAP Fiori Elements (RAP Managed + Draft, OData V4)

SAP Fiori Elements (List Report + Object Page แบบ Draft) บน SAP S/4HANA Public Cloud สำหรับแอปพลิเคชัน **"Coverage - LME Price"** พัฒนาตามสถาปัตยกรรม ABAP RESTful Application Programming Model (RAP Managed with Draft, Strict 2, ABAP Cloud) ออกแบบให้โครงสร้าง หน้าตา และพฤติกรรมการทำงานตรงกับ Mockup HTML (`GR_With_IBD_App.html`)

---

## 1. ข้อมูลทั่วไปของโปรเจกต์ (Project Overview)

- **Package**: `ZTOM_AI`
- **Module / Topic**: `SD / ZSDCDP`
- **GitHub Repository**: [https://github.com/ntz-panupong/TESTGENSALE](https://github.com/ntz-panupong/TESTGENSALE)
- **Git Author**: `ntz-panupong <bpanupong@netizen.co.th>`
- **ABAP Cloud Language Version**: 5 (ABAP for Cloud Development)
- **Draft & Transactional Model**: Managed with Draft, Strict (2), Numbering Managed (UUID)

---

## 2. ตารางรายการ Objects (Artifacts & Companions)

| Object Type | Object Name | File Names | รายละเอียด / ความรับผิดชอบ |
| :--- | :--- | :--- | :--- |
| **DEVC** | `ZTOM_AI` | `package.devc.xml` | Package สำหรับแอปพลิเคชัน Coverage LME Price |
| **DOMA** | `ZDM_SD_ZSDCDPRSN` | `zdm_sd_zsdcdprsn.doma.xml` | Domain สำหรับ Condition Code (Fixed Values: `ZSD`, `ZFE`, `ZOR`) |
| **DTEL** | `ZELM_SD_ZSDCDPRSN`| `zelm_sd_zsdcdprsn.dtel.xml`| Data Element สำหรับ Condition Price Code |
| **DOMA** | `ZDM_SD_ZSDCDPSTAT`| `zdm_sd_zsdcdpstat.doma.xml`| Domain สำหรับ Status (`INCOMPLETE`, `COMPLETED`) |
| **DTEL** | `ZELM_SD_ZSDCDPSTAT`| `zelm_sd_zsdcdpstat.dtel.xml`| Data Element สำหรับ Status |
| **TABL** | `ZSDTZSD` | `zsdtzsd.tabl.xml` | ตาราง Persistent Data เก็บข้อมูล Header & Condition |
| **TABL** | `ZSDTZSDD` | `zsdtzsdd.tabl.xml` | Draft Table (ตรงตาม CDS element + `.INCLUDE SYCH_BDL_DRAFT_ADMIN_INC`) |
| **DDLS** | `ZI_SD_ZSDCDPRSN_VH`| `zi_sd_zsdcdprsn_vh.ddls.*` | Value Help สำหรับ Fixed Values บน `DDCDS_CUSTOMER_DOMAIN_VALUE_T` |
| **DDLS** | `ZI_SD_ZSDCDP_VH` | `zi_sd_zsdcdp_vh.ddls.*` | Value Help สำหรับ Sale Order (กรองเฉพาะ Incomplete GR / Open Orders) |
| **DDLS** | `ZI_SD_ZSDCDPITEM` | `zi_sd_zsdcdpitem.ddls.*` | Read-only Item CDS ดึง Condition จาก `I_SalesOrderItemPricingElement` |
| **DDLS** | `ZI_SD_ZSDCDP` | `zi_sd_zsdcdp.ddls.*` | Root Interface CDS View Entity |
| **BDEF** | `ZI_SD_ZSDCDP` | `zi_sd_zsdcdp.bdef.*` | Behavior Definition (Managed + Draft, Strict 2) |
| **DDLS** | `ZC_SD_ZSDCDP` | `zc_sd_zsdcdp.ddls.*` | Projection CDS View Entity (`transactional_query`) |
| **BDEF** | `ZC_SD_ZSDCDP` | `zc_sd_zsdcdp.bdef.*` | Projection Behavior Definition |
| **DDLX** | `ZC_SD_ZSDCDP` | `zc_sd_zsdcdp.ddlx.*` | UI Metadata Extension (HeaderInfo, Facets, LineItem, SelectionField) |
| **CLAS** | `ZBP_I_SD_ZSDCDP` | `zbp_i_sd_zsdcdp.clas.*` | Behavior Pool Handler Class สำหรับ RAP determinations, validations, actions |
| **CLAS** | `ZCL_SD_ZSDCDP_ACTION` | `zcl_sd_zsdcdp_action.clas.*` | Business Logic Class รวม logic คำนวณ, MAX+1, และ EML standard |
| **SRVD** | `ZSD_SD_ZSDCDP_SRV` | `zsd_sd_zsdcdp_srv.srvd.*` | Service Definition สำหรับ expose entities สู่ OData V4 |
| **SRVB** | `ZSB_SD_ZSDCDP_UI` | *(Manual ใน ADT)* | Service Binding OData V4 - UI |

---

## 3. พฤติกรรมและการทำงาน (Business Logic & RAP Behaviors)

### 3.1 การจัดการหมายเลขเอกสาร (Document Numbering)
- ดำเนินการผ่าน Determination on Save `setDocumentNumber`
- คำนวณ `CoverageID` อัตโนมัติด้วยคำสั่ง `SELECT MAX` ใน `ZCL_SD_ZSDCDP_ACTION=>get_next_coverage_id`

### 3.2 สถานะและ Criticality (Status Management)
- กำหนดค่าเริ่มต้น `OverallStatus = 'INCOMPLETE'` และ `StatusCriticality = 2` (สีส้ม/Warning) ตอน Create ผ่าน Determination on Modify `setInitialStatus`
- เมื่อดำเนินการ Action `createPriceConditionAndUpdate` จะอัปเดตเป็น `OverallStatus = 'COMPLETED'` และ `StatusCriticality = 3` (สีเขียว/Success)

### 3.3 Dynamic Instance Features (`get_instance_features`)
- เอกสารที่อยู่ในสถานะ `COMPLETED` จะถูก Disable ปุ่ม Edit, Delete และ Action `createPriceConditionAndUpdate` โดยอัตโนมัติ

### 3.4 การตรวจสอบความถูกต้อง (Validations on Save)
- ตรวจสอบ `SalesOrder` ต้องไม่เป็นค่าว่าง
- ตรวจสอบ Condition Price:
  - `ConditionPriceValue` ต้องไม่เป็น 0 หรือว่าง
  - `ConditionPriceCurrency` ต้องไม่ว่าง
  - `ConditionCode` ต้องไม่ว่าง
- หากพบข้อผิดพลาด จะส่งข้อความแจ้งเตือนตามข้อกำหนด:
  > **"กรุณาตรวจสอบข้อมูล Sale Order : xxxxxx Item : xxxxxx"**
- ใส่ Validation ไว้ใน `draft determine action Prepare` เพื่อให้ Fiori Elements แสดงกรอบสีแดงที่ฟิลด์และเปิด Message Popover ที่ Footer ได้ทันทีก่อนการ Save

---

## 4. ข้อจำกัดของ RAP และจุดที่ต้อง VERIFY (Technical Considerations)

### 4.1 ข้อจำกัด: การอัปเดต Standard Business Object
- **กฎเหล็กของ RAP**: ห้ามเรียก EML เพื่อแก้ไข Standard Business Object (เช่น `MODIFY ENTITIES OF I_SalesOrderTP`) ภายใน `SAVE` phase (`FINALIZE` หรือ `SAVE`) เนื่องจากระบบจะเกิด Nested LUW / Transaction conflict
- **วิธีแก้ไขที่ใช้**: 
  - การบันทึกและ Activate Draft ของ Coverage ดำเนินการตามปกติใน RAP Transaction
  - การเชื่อมโยงเพื่อปรับปรุง Standard Sales Order Pricing ทำผ่าน Action `createPriceConditionAndUpdate` ใน **Interaction Phase**
  - EML สำหรับแก้ไข Standard BO ถูกรวมศูนย์ไว้ใน `ZCL_SD_ZSDCDP_ACTION=>update_sales_order_price` เพียงแห่งเดียว

### 4.2 จุดที่ต้อง VERIFY ในระบบ SAP S/4HANA Public Cloud ของคุณ
1. **Released BO Interface**: ตรวจสอบว่า `I_SalesOrderTP` หรือ `I_SalesOrderItemPricingElementTP` มีสถานะ Released (C1) ใน Cloud Release ปัจจุบันของคุณหรือไม่
2. **Standard Value Help CDS**: ตรวจสอบว่า `I_SalesOrder` และ `I_SalesOrderItemPricingElement` พร้อมใช้งานและมีสิทธิ์เข้าถึงใน Tenant

---

## 5. ลำดับการ Activate ใน ADT (Activation Order)

เมื่อ Pull ผ่าน abapGit เข้ามาใน ADT ให้ทำการ Activate ตามลำดับความขึ้นต่อกันดังนี้:

1. **Domains & Data Elements**:
   - `ZDM_SD_ZSDCDPRSN` → `ZELM_SD_ZSDCDPRSN`
   - `ZDM_SD_ZSDCDPSTAT` → `ZELM_SD_ZSDCDPSTAT`
2. **Database Tables**:
   - `ZSDTZSD` (Persistent Table)
   - `ZSDTZSDD` (Draft Table)
3. **Value Help & Item CDS Views**:
   - `ZI_SD_ZSDCDPRSN_VH`
   - `ZI_SD_ZSDCDP_VH`
   - `ZI_SD_ZSDCDPITEM`
4. **Root CDS Views**:
   - `ZI_SD_ZSDCDP`
   - `ZC_SD_ZSDCDP`
5. **UI Metadata Extension**:
   - `ZC_SD_ZSDCDP` (DDLX)
6. **Business Logic Class**:
   - `ZCL_SD_ZSDCDP_ACTION`
7. **Behavior Definitions & Pool**:
   - `ZI_SD_ZSDCDP` (BDEF) + `ZBP_I_SD_ZSDCDP` (CLAS)
   - `ZC_SD_ZSDCDP` (BDEF)
8. **Service Definition**:
   - `ZSD_SD_ZSDCDP_SRV`
9. **Service Binding (สร้าง Manual ใน ADT)**:
   - `ZSB_SD_ZSDCDP_UI` (OData V4 - UI) → Activate → Publish

---

## 6. คำแนะนำการ Pull เข้า ADT ผ่าน abapGit Repositories

1. เปิด Eclipse ADT ที่เชื่อมต่อกับระบบ SAP S/4HANA Public Cloud
2. ไปที่เมนู **Window** → **Show View** → **Other...** → พิมพ์ค้นหา **"abapGit Repositories"**
3. คลิกปุ่ม **+** (Clone Repository):
   - **Repository URL**: `https://github.com/ntz-panupong/TESTGENSALE`
   - **Package**: `ZTOM_AI`
   - **Branch**: `refs/heads/main`
   - **Folder Logic**: `FULL`
4. คลิกขวาที่ Repository ในมุมมอง abapGit → เลือก **Pull**
5. เลือก Transport Request (TR) ที่ต้องการ → กด **Finish**
6. ทำการ Activate อ็อบเจกต์ตามลำดับในหัวข้อที่ 5
7. สร้าง Service Binding `ZSB_SD_ZSDCDP_UI` (Binding Type: `OData V4 - UI`), กด Activate และ Publish เพื่อทดสอบ Preview หน้าแอป Fiori Elements
