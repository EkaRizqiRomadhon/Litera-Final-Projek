import '../models/book_model.dart';

class LocalBookService {
  static final List<BookModel> localBooks = [
    BookModel(
      id: 'local_cantik_itu_luka',
      title: 'Cantik Itu Luka',
      authors: ['Eka Kurniawan'],
      publisher: 'Gramedia Pustaka Utama',
      publishedDate: '2002-03-01',
      description: 'Cantik itu Luka, novel pertama Eka Kurniawan, berkisah tentang Dewi Ayu, seorang pelacur legendaris di zaman akhir kolonial, dan anak-anak perempuannya yang cantik namun dikutuk oleh kecantikan mereka.',
      pageCount: 508,
      categories: ['Sastra Indo', 'Novel'],
      averageRating: 4.8,
      ratingsCount: 120,
      language: 'id',
      previewLink: '',
      infoLink: '',
      thumbnail: 'https://lhakcofpljwbtoydeaqv.supabase.co/storage/v1/object/public/cover_book/cantik_itu_luka_cover.jpg',
      pdfDownloadLink: 'https://lhakcofpljwbtoydeaqv.supabase.co/storage/v1/object/public/book/cantik_itu_luka.pdf',
      isEbook: true,
    ),
    BookModel(
      id: 'local_ronggeng_dukuh_paruk',
      title: 'Ronggeng Dukuh Paruk',
      authors: ['Ahmad Tohari'],
      publisher: 'Gramedia Pustaka Utama',
      publishedDate: '1982-01-01',
      description: 'Ronggeng Dukuh Paruk adalah sebuah novel yang menceritakan kehidupan Srintil, seorang penari ronggeng di sebuah dusun terpencil bernama Dukuh Paruk yang penuh dengan tradisi dan tragedi politik.',
      pageCount: 408,
      categories: ['Sastra Indo', 'Novel'],
      averageRating: 4.7,
      ratingsCount: 95,
      language: 'id',
      previewLink: '',
      infoLink: '',
      thumbnail: 'https://lhakcofpljwbtoydeaqv.supabase.co/storage/v1/object/public/cover_book/ronggeng_dukuh_paruk_cover.jpeg',
      pdfDownloadLink: 'https://lhakcofpljwbtoydeaqv.supabase.co/storage/v1/object/public/book/ronggeng_dukuh_paruk.pdf',
      isEbook: true,
    ),
    BookModel(
      id: 'local_sejarah_disembunyikan',
      title: 'Sejarah Dunia yang Disembunyikan',
      authors: ['Jonathan Black'],
      publisher: 'Pustaka Alvabet',
      publishedDate: '2007-01-01',
      description: 'Jonathan Black mengupas misteri dan sejarah alternatif dunia dari perspektif berbagai perkumpulan rahasia dan ajaran esoterik sejak zaman dahulu kala.',
      pageCount: 636,
      categories: ['Sejarah'],
      averageRating: 4.6,
      ratingsCount: 88,
      language: 'id',
      previewLink: '',
      infoLink: '',
      thumbnail: 'https://lhakcofpljwbtoydeaqv.supabase.co/storage/v1/object/public/cover_book/sejarah_dunia_yang_disembunyikan_cover.jpg',
      pdfDownloadLink: 'https://lhakcofpljwbtoydeaqv.supabase.co/storage/v1/object/public/book/sejarah_disembunyikan.pdf',
      isEbook: true,
    ),
    BookModel(
      id: 'local_thermodynamics',
      title: 'Fundamentals of Engineering Thermodynamics',
      authors: ['Michael J. Moran', 'Howard N. Shapiro', 'Daisie D. Boettner', 'Margaret B. Bailey'],
      publisher: 'Wiley',
      publishedDate: '2014-01-01',
      description: 'The classic textbook on engineering thermodynamics, providing a comprehensive and detailed explanation of thermodynamic principles.',
      pageCount: 1024,
      categories: ['Teknologi', 'Sains'],
      averageRating: 4.5,
      ratingsCount: 42,
      language: 'en',
      previewLink: '',
      infoLink: '',
      thumbnail: 'https://lhakcofpljwbtoydeaqv.supabase.co/storage/v1/object/public/cover_book/thermodynamics.jpeg',
      pdfDownloadLink: 'https://lhakcofpljwbtoydeaqv.supabase.co/storage/v1/object/public/book/thermodynamics.pdf',
      isEbook: true,
    ),
    BookModel(
      id: 'local_konflik_kolaborasi',
      title: 'Konflik dan Kolaborasi: Peran Negara dalam Integrasi Bangsa',
      authors: ['Kementerian Pendidikan dan Kebudayaan'],
      publisher: 'Kemendikbud',
      publishedDate: '2021-01-01',
      description: 'Buku ini membahas mengenai konflik dan kolaborasi serta peran penting negara dalam upaya membangun integrasi bangsa Indonesia.',
      pageCount: 120,
      categories: ['Sejarah Indo', 'Edukasi'],
      averageRating: 4.4,
      ratingsCount: 30,
      language: 'id',
      previewLink: '',
      infoLink: '',
      thumbnail: 'https://lhakcofpljwbtoydeaqv.supabase.co/storage/v1/object/public/cover_book/konflik.webp',
      pdfDownloadLink: 'https://lhakcofpljwbtoydeaqv.supabase.co/storage/v1/object/public/book/konflik_kolaborasi.pdf',
      isEbook: true,
    ),
    BookModel(
      id: 'local_broken_strings',
      title: 'Broken Strings',
      authors: ['Aurelie Moeremans'],
      publisher: 'Litera Publisher',
      publishedDate: '2023-01-01',
      description: 'Kisah romansa penuh intrik dan perjuangan emosional yang menyentuh hati para pembaca.',
      pageCount: 280,
      categories: ['Novel', 'Romance'],
      averageRating: 4.5,
      ratingsCount: 54,
      language: 'id',
      previewLink: '',
      infoLink: '',
      thumbnail: 'https://lhakcofpljwbtoydeaqv.supabase.co/storage/v1/object/public/cover_book/broken_strings_cover.jpg',
      pdfDownloadLink: 'https://lhakcofpljwbtoydeaqv.supabase.co/storage/v1/object/public/book/broken_strings.pdf',
      isEbook: true,
    ),
    BookModel(
      id: 'local_Filosofi_Teras',
      title: 'Filosofi Teras',
      authors: ['Henry Manampiring'],
      publisher: 'Gramedia Pustaka Utama',
      publishedDate: '2018-01-01',
      description: 'Filosofi Teras adalah buku yang membahas mengenai filsafat stoa.',
      pageCount: 344,
      categories: ['Filsafat'],
      averageRating: 4.6,
      ratingsCount: 88,
      language: 'id',
      previewLink: '',
      infoLink: '',
      thumbnail: 'https://lhakcofpljwbtoydeaqv.supabase.co/storage/v1/object/public/cover_book/filosofi_teras_cover.jpg',
      pdfDownloadLink: 'https://lhakcofpljwbtoydeaqv.supabase.co/storage/v1/object/public/book/Filosofi_Teras.pdf',
      isEbook: true,
    ),
    BookModel(
      id: 'local_Bumi_Manusia',
      title: 'Bumi Manusia',
      authors: ['Pramoedya Ananta Toer'],
      publisher: 'Lentera Dipantara',
      publishedDate: '1980-01-01',
      description: 'Bumi Manusia adalah novel karya Pramoedya Ananta Toer yang menceritakan kehidupan Minke, seorang pribumi terpelajar pada masa kolonial Hindia Belanda.',
      pageCount: 535,
      categories: ['Novel', 'Sejarah'],
      averageRating: 4.8,
      ratingsCount: 120,
      language: 'id',
      previewLink: '',
      infoLink: '',
      thumbnail: 'https://lhakcofpljwbtoydeaqv.supabase.co/storage/v1/object/public/cover_book/Bumi%20Manusia.jpg',
      pdfDownloadLink: 'https://lhakcofpljwbtoydeaqv.supabase.co/storage/v1/object/public/book/Bumi-Manusia.pdf',
      isEbook: true,
      ),
      BookModel(
      id: 'local_Laskar_Pelangi',
      title: 'Laskar Pelangi',
      authors: ['Andrea Hirata'],
      publisher: 'Bentang Pustaka',
      publishedDate: '2005-01-01',
      description: 'Laskar Pelangi adalah novel karya Andrea Hirata yang menceritakan kisah persahabatan dan perjuangan sekelompok anak di Belitung untuk mendapatkan pendidikan.',
      pageCount: 529,
      categories: ['Novel', 'Fiksi'],
      averageRating: 4.7,
      ratingsCount: 150,
      language: 'id',
      previewLink: '',
      infoLink: '',
      thumbnail: 'https://lhakcofpljwbtoydeaqv.supabase.co/storage/v1/object/public/cover_book/Laskar%20Pelangi%20Design_%20Andreas%20Kusumahadi.jpg',
      pdfDownloadLink: 'https://lhakcofpljwbtoydeaqv.supabase.co/storage/v1/object/public/book/laskar%20pelani.pdf',
      isEbook: true,
    ),
    BookModel(
      id: 'local_Negeri_5_Menara',
      title: 'Negeri 5 Menara',
      authors: ['Ahmad Fuadi'],
      publisher: 'Gramedia Pustaka Utama',
      publishedDate: '2009-01-01',
      description: 'Negeri 5 Menara adalah novel inspiratif karya Ahmad Fuadi yang menceritakan perjuangan enam santri di Pondok Madani untuk meraih mimpi mereka dengan semboyan “Man Jadda Wajada”.',
      pageCount: 423,
      categories: ['Novel', 'Inspirasi'],
      averageRating: 4.7,
      ratingsCount: 95,
      language: 'id',
      previewLink: '',
      infoLink: '',
      thumbnail: 'https://lhakcofpljwbtoydeaqv.supabase.co/storage/v1/object/public/cover_book/Negeri%205%20Menara.jpg',
      pdfDownloadLink: 'https://lhakcofpljwbtoydeaqv.supabase.co/storage/v1/object/public/book/negeri-5-menara.pdf',
      isEbook: true,
    ),
  ];

  /// Get books matching category
  static List<BookModel> getBooksByCategory(String category) {
    if (category == 'Semua') return localBooks;
    final catLower = category.toLowerCase();
    return localBooks.where((book) {
      return book.categories.any((c) => c.toLowerCase().contains(catLower));
    }).toList();
  }

  /// Search local books
  static List<BookModel> searchBooks(String query) {
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase();
    return localBooks.where((book) {
      return book.title.toLowerCase().contains(q) ||
             book.authorsDisplay.toLowerCase().contains(q) ||
             book.categories.any((c) => c.toLowerCase().contains(q));
    }).toList();
  }

  /// Find local book by matching title (case-insensitive, substring)
  static BookModel? findLocalBookByTitle(String title) {
    final cleanTitle = title.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    if (cleanTitle.isEmpty) return null;
    for (var book in localBooks) {
      final bookClean = book.title.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
      if (cleanTitle.contains(bookClean) || bookClean.contains(cleanTitle)) {
        return book;
      }
    }
    return null;
  }
}

