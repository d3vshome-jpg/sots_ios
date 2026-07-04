package org.sots.pwww.sotspw_ios

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform