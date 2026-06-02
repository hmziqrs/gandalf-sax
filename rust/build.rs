fn main() {
    #[cfg(windows)]
    {
        let mut res = winres::WindowsResource::new();
        res.set_icon("assets/icon.ico");
        res.setProductName("Epic Sax Gandalf");
        res.setFileDescription("Epic Sax Gandalf - NTP-synced infinite video loop");
        res.setCompanyName("com.onemdev");
        res.compile().expect("Failed to compile Windows resources");
    }
}
