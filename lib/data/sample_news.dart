import 'models.dart';

const sampleNews = Promotion(
  id: 'sample-thadingyut',
  title: 'သီတင်းကျွတ်',
  body: 'မြို့တွင်းက\nအချိန်အခါမရွေးလှည့်ပတ်နိုင်...',
  discountLabel: '',
  endsAt: null,
  imageAsset: 'assets/rewards/thadingyut.jpg',
);

List<Promotion> withSampleNews(List<Promotion> items) {
  if (items.any((item) => item.id == sampleNews.id)) {
    return items;
  }
  return [sampleNews, ...items];
}
