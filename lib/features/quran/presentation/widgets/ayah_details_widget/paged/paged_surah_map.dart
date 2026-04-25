class SurahRange {
  final int start;
  final int end;
  SurahRange(this.start, this.end);
}

final Map<int, SurahRange> surahPageRanges = {
  1: SurahRange(1, 1),
  2: SurahRange(2, 49),
  3: SurahRange(50, 76),
  4: SurahRange(77, 106), // Shared page 106
  5: SurahRange(106, 127),
  6: SurahRange(128, 150),
  7: SurahRange(151, 176),
  8: SurahRange(177, 186),
  9: SurahRange(187, 207),
  10: SurahRange(208, 221), // Shared page 221
  11: SurahRange(221, 235), // Shared page 235
  12: SurahRange(235, 248),
  13: SurahRange(249, 255), // Shared page 255
  14: SurahRange(255, 261),
  15: SurahRange(262, 267), // Shared page 267
  16: SurahRange(267, 281),
  17: SurahRange(282, 293), // Shared page 293
  18: SurahRange(293, 304),
  19: SurahRange(305, 312), // Shared page 312
  20: SurahRange(312, 321),
  21: SurahRange(322, 331),
  22: SurahRange(332, 341),
  23: SurahRange(342, 350), // Shared page 350
  24: SurahRange(350, 359), // Shared page 359
  25: SurahRange(359, 366),
  26: SurahRange(367, 376),
  27: SurahRange(377, 385), // Shared page 385
  28: SurahRange(385, 396), // Shared page 396
  29: SurahRange(396, 404), // Shared page 404
  30: SurahRange(404, 410),
  31: SurahRange(411, 414),
  32: SurahRange(415, 417),
  33: SurahRange(418, 427),
  34: SurahRange(428, 434), // Shared page 434
  35: SurahRange(434, 439),
  36: SurahRange(440, 445),
  37: SurahRange(446, 452),
  38: SurahRange(453, 458), // Shared page 458
  39: SurahRange(458, 466),
  40: SurahRange(467, 476),
  41: SurahRange(477, 482),
  42: SurahRange(483, 489), // Shared page 489
  43: SurahRange(489, 495),
  44: SurahRange(496, 498),
  45: SurahRange(499, 501),
  46: SurahRange(502, 506),
  47: SurahRange(507, 510),
  48: SurahRange(511, 515), // Shared page 515
  49: SurahRange(515, 517),
  50: SurahRange(518, 520), // Shared page 520
  51: SurahRange(520, 523), // Shared page 523
  52: SurahRange(523, 525),
  53: SurahRange(526, 528), // Shared page 528
  54: SurahRange(528, 531), // Shared page 531
  55: SurahRange(531, 534), // Shared page 534
  56: SurahRange(534, 537), // Shared page 537
  57: SurahRange(537, 541),
  58: SurahRange(542, 545), // Shared page 545
  59: SurahRange(545, 548),
  60: SurahRange(549, 551), // Shared page 551
  61: SurahRange(551, 552),
  62: SurahRange(553, 554), // Shared page 554
  63: SurahRange(554, 555),
  64: SurahRange(556, 558), // Shared page 558
  65: SurahRange(558, 560), // Shared page 560
  66: SurahRange(560, 561),
  67: SurahRange(562, 564), // Shared page 564
  68: SurahRange(564, 566), // Shared page 566
  69: SurahRange(566, 568), // Shared page 568
  70: SurahRange(568, 570), // Shared page 570
  71: SurahRange(570, 572), // Shared page 572
  72: SurahRange(572, 573),
  73: SurahRange(574, 575), // Shared page 575
  74: SurahRange(575, 577), // Shared page 577
  75: SurahRange(577, 578), // Al-Qiyamah: 577 to 578 (Shared 578 with Al-Insan)
  76: SurahRange(578, 580), // Al-Insan: 578 to 580
  77: SurahRange(580, 581),
  78: SurahRange(582, 583), // Shared page 583
  79: SurahRange(583, 584),
  80: SurahRange(585, 585),
  81: SurahRange(586, 586),
  82: SurahRange(587, 587),
  83: SurahRange(587, 589), // Shared 587 and 589
  84: SurahRange(589, 590),
  85: SurahRange(590, 590),
  86: SurahRange(591, 591),
  87: SurahRange(591, 592), // Shared 591 and 592
  88: SurahRange(592, 592),
  89: SurahRange(593, 594), // Shared 594
  90: SurahRange(594, 595), // Shared 594 and 595
  91: SurahRange(595, 595),
  92: SurahRange(595, 596), // Shared 595 and 596
  93: SurahRange(596, 596),
  94: SurahRange(596, 597), // Shared 596 and 597
  95: SurahRange(597, 597),
  96: SurahRange(597, 598), // Shared 597 and 598
  97: SurahRange(598, 598),
  98: SurahRange(598, 599), // Shared 598 and 599
  99: SurahRange(599, 599),
  100: SurahRange(599, 600), // Shared 599 and 600
  101: SurahRange(600, 600),
  102: SurahRange(600, 601), // Shared 600 and 601
  103: SurahRange(601, 601),
  104: SurahRange(601, 601),
  105: SurahRange(601, 602), // Shared 601 and 602
  106: SurahRange(602, 602),
  107: SurahRange(602, 602),
  108: SurahRange(602, 603), // Shared 602 and 603
  109: SurahRange(603, 603),
  110: SurahRange(603, 603),
  111: SurahRange(603, 604), // Shared 603 and 604
  112: SurahRange(604, 604),
  113: SurahRange(604, 604),
  114: SurahRange(604, 604),
};

List<int> getSurahNumbersFromPage(int pageNumber) {
  List<int> surahsOnPage = [];

  surahPageRanges.forEach((surahNum, range) {
    if (pageNumber >= range.start && pageNumber <= range.end) {
      surahsOnPage.add(surahNum);
    }
  });

  return surahsOnPage;
}
