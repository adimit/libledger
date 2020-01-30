import 'package:petitparser/debug.dart' as petit_parser;
import 'package:petitparser/petitparser.dart';

import 'grammar.dart';

Result trace(String text) =>
    petit_parser.trace(LedgerGrammarDefinition().build()).parse(text);
Result progress(String text) =>
    petit_parser.progress(LedgerGrammarDefinition().build()).parse(text);
Result profile(String text) =>
    petit_parser.profile(LedgerGrammarDefinition().build()).parse(text);
