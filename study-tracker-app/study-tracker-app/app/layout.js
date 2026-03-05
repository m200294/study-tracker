import "./globals.css";

export const metadata = {
  title: "Study Tracker",
  description: "Exam study tracker — ADS2 · PWD · HCW — March 2026",
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
