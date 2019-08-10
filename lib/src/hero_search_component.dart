import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:stream_transform/stream_transform.dart';
import 'route_paths.dart';
import 'hero_search_service.dart';
import 'hero.dart';

@Component(
  selector: 'hero-search',
  templateUrl: 'hero_search_component.html',
  styleUrls: ['hero_search_component.css'],
  directives: [coreDirectives],
  providers: [ClassProvider(HeroSearchService)],
  pipes: [commonPipes],
)
class HeroSearchComponent implements OnInit {
  HeroSearchService _heroSearchService;
  Router _router;
  StreamController<String> _searchTerms = StreamController<String>.broadcast();

  Stream<List<Hero>> heroes;

  HeroSearchComponent(this._heroSearchService, this._router) {}

  void search(String term) => _searchTerms.add(term);

  /*
    turn the stream of search terms into a stream of Hero lists 
    and assign the result to the heroes property

    transform(debounce(... 300))) 
    waits until the flow of search terms pauses for 300 milliseconds before passing 
    along the latest string. You’ll never make requests more frequently than 300ms.
    
    distinct() ensures that a request is sent only if the filter text changed.
    
    transform(switchMap(...)) 
    calls the search service for each search term that makes it through debounce() 
    and distinct(). It cancels and discards previous searches, returning only the 
    latest search service stream element.
    
    handleError() 
    handles errors. The simple example prints the error to the console; a real 
    life app should do better.

  */
  void ngOnInit() async {
    heroes = _searchTerms.stream
        .transform(debounce(Duration(milliseconds: 300)))
        .distinct()
        .transform(switchMap((term) => term.isEmpty
            ? Stream<List<Hero>>.fromIterable([<Hero>[]])
            : _heroSearchService.search(term).asStream()))
        .handleError((e) {
      print(e); // for demo purposes only
    });
  }

  String _heroUrl(int id) =>
      RoutePaths.hero.toUrl(parameters: {idParam: '$id'});

  Future<NavigationResult> gotoDetail(Hero hero) =>
      _router.navigate(_heroUrl(hero.id));
}