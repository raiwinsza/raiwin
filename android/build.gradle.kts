// Root-level build.gradle.kts

plugins {
    // เพิ่ม Google Services plugin แต่ยังไม่เปิดใช้งานตรงนี้
    id("com.google.gms.google-services") version "4.3.15" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// กำหนดโฟลเดอร์ build ใหม่ (ตามของเดิมคุณ)
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// ทำให้ subprojects ประเมินค่า app ก่อน
subprojects {
    project.evaluationDependsOn(":app")
}

// task clean
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}


