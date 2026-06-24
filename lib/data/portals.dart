import '../models/portal.dart';

/// Static, offline-config-driven list of every portal Kloud TV knows about.
///
/// To add a new portal, append an entry here - no backend or build step
/// required.
const List<Portal> kPortals = [
  // ---------------------------------------------------------------------
  // Movies
  // ---------------------------------------------------------------------
  Portal(
    name: 'Bein Sports 1',
    url: 'http://moviemazic.xyz/live-tv/bein-sports-1.html',
    category: PortalCategory.movies,
    isFeatured: true,
  ),
  Portal(
    name: 'Circle FTP',
    url: 'http://circleftp.net/',
    category: PortalCategory.movies,
    isFeatured: true,
  ),
  Portal(
    name: 'Circle FTP New',
    url: 'http://new.circleftp.net/',
    category: PortalCategory.movies,
  ),
  Portal(
    name: 'DflixSAM',
    url: 'http://172.16.50.4/',
    category: PortalCategory.movies,
  ),
  Portal(
    name: 'Flix.Live',
    url: 'http://dflix.live/',
    category: PortalCategory.movies,
  ),
  Portal(
    name: 'Movies Discovery',
    url: 'https://movies.discoveryftp.net/',
    category: PortalCategory.movies,
    isFeatured: true,
  ),
  Portal(
    name: 'Discovery FTP',
    url: 'https://discoveryftp.net/',
    category: PortalCategory.movies,
  ),
  Portal(
    name: 'MovieHaat',
    url: 'https://moviehaat.net/',
    category: PortalCategory.movies,
  ),
  Portal(
    name: '11Plus Movies',
    url: 'http://flix.11plus.live/',
    category: PortalCategory.movies,
  ),
  Portal(
    name: 'DhakaMovie',
    url: 'http://172.17.50.240/',
    category: PortalCategory.movies,
  ),
  Portal(
    name: 'TimePass',
    url: 'http://timepassbd.live/',
    category: PortalCategory.movies,
  ),
  Portal(
    name: 'FTP-BD',
    url: 'https://ftpbd.net/',
    category: PortalCategory.movies,
  ),
  Portal(
    name: 'TeraPlex',
    url: 'http://tetraplex.net.bd/',
    category: PortalCategory.movies,
  ),
  Portal(
    name: 'BokaSoka',
    url: 'http://bokasoka.net/',
    category: PortalCategory.movies,
  ),
  Portal(
    name: 'Z-FLIX',
    url: 'http://zflixbd.com/',
    category: PortalCategory.movies,
  ),
  Portal(
    name: 'WC-FTP',
    url: 'http://172.22.22.101/webhome/',
    category: PortalCategory.movies,
  ),
  Portal(
    name: 'WoW',
    url: 'http://172.27.27.84/',
    category: PortalCategory.movies,
  ),
  Portal(
    name: 'Fs Ebox',
    url: 'http://fs.ebox.live/',
    category: PortalCategory.movies,
  ),
  Portal(
    name: 'ICC FTP',
    url: 'http://10.16.100.244/',
    category: PortalCategory.movies,
  ),
  Portal(
    name: 'Relax Time FTP',
    url: 'http://10.100.100.10/',
    category: PortalCategory.movies,
  ),

  // ---------------------------------------------------------------------
  // Live TV
  // ---------------------------------------------------------------------
  Portal(
    name: '11Plus Live TV',
    url: 'http://flix.11plus.live/live-tv.html',
    category: PortalCategory.liveTv,
    isFeatured: true,
  ),
  Portal(
    name: 'TSports Live',
    url: 'http://172.19.17.28/',
    category: PortalCategory.liveTv,
    isFeatured: true,
  ),
  Portal(
    name: 'Local TV',
    url: 'http://10.99.99.99/',
    category: PortalCategory.liveTv,
  ),
  Portal(
    name: 'BD Live',
    url: 'http://redforce.live/',
    category: PortalCategory.liveTv,
  ),
  Portal(
    name: 'BD TV',
    url: 'http://10.30.30.30/',
    category: PortalCategory.liveTv,
  ),
  Portal(
    name: 'Nemo TV',
    url: 'http://10.99.99.99/',
    category: PortalCategory.liveTv,
  ),
  Portal(
    name: 'RoarZone TV',
    url: 'http://tv.roarzone.info/',
    category: PortalCategory.liveTv,
  ),
  Portal(
    name: 'ST TV',
    url: 'http://10.20.30.40/',
    category: PortalCategory.liveTv,
  ),
  Portal(
    name: 'DugDugi TV',
    url: 'http://dugdugilive.com/',
    category: PortalCategory.liveTv,
  ),
  Portal(
    name: 'NowHDTimes',
    url: 'https://nowhdtime.com.bd/',
    category: PortalCategory.liveTv,
  ),


  



];
