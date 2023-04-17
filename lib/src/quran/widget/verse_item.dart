import 'package:flutter/material.dart';
import 'package:quran_app/src/settings/theme/app_theme.dart';

class VerseItem extends StatelessWidget {
  const VerseItem({
    Key? key,
    this.verse,
    this.textTranslation,
    this.verseNumber,
    this.transcription,
    this.author,
    this.surahName,
    required this.onTapSeeTafsir,
  }) : super(key: key);
  final String? verse;
  final String? textTranslation;
  final int? verseNumber;
  final String? transcription;
  final String? author;
  final String? surahName;
  final void Function() onTapSeeTafsir;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppShadow.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$surahName",
                style: AppTextStyle.normal.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(width: 5,),
              Container(
                height: 30,
                width: 30,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: FittedBox(
                    child: Text(
                      "$verseNumber",
                      style: AppTextStyle.normal.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              Spacer(),
              Text(
                "$author",
                style: AppTextStyle.normal.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(left: 40),
              child: Text(
                "$verse",
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.normal,
                  fontFamily: "Uthmani",
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "$transcription",
            style: AppTextStyle.normal.copyWith(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            textTranslation!.replaceAll(RegExp('\\[.*?\\]'), ''),
            style: AppTextStyle.normal.copyWith(fontSize: 14),
            textAlign: TextAlign.start,
          ),
          InkWell(
            onTap: onTapSeeTafsir,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [AppShadow.card],
              ),
              child: Center(
                child: Text(
                  "Arapça kelime anlamlarını ve meal çevirilerini gör",
                  style: AppTextStyle.normal.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
