import 'package:flutter/material.dart';

IconData learningDomainIcon(String domainId) => switch (domainId) {
  'programmation' || 'algorithmique' => Icons.code_rounded,
  'developpement-web' => Icons.web_outlined,
  'developpement-mobile' => Icons.phone_android_outlined,
  'intelligence-artificielle' => Icons.psychology_outlined,
  'cybersecurite' => Icons.security_outlined,
  'bases-de-donnees' => Icons.storage_outlined,
  'mathematiques' => Icons.calculate_outlined,
  'sciences' => Icons.science_outlined,
  'langues' => Icons.translate_rounded,
  'bureautique' => Icons.table_chart_outlined,
  'design-graphique' => Icons.palette_outlined,
  _ => Icons.menu_book_outlined,
};
