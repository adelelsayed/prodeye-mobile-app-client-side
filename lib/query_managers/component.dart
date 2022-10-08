import 'package:prodeye/models/component.dart';
import 'package:prodeye/query_managers/component_queue_and_messages.dart';
import 'package:prodeye/query_managers/query_manager.dart';

class ComponentQuery extends QueryManager {
  List<Component> components = [];
  ComponentQuery(String pParentId) {
    parentId = pParentId;
  }
  @override
  Future<void> prepare(var parentObject) async {
    if (!this.isPrepared) {
      List<Map<String, Object?>> rawComponents =
          await Component.query("productionParent", "=", int.parse(parentId));
      rawComponents.forEach((element) {
        Component currComponent = Component(
            name: element["name"].toString(), type: element["type"].toString());
        currComponent.id = int.parse(element["ID"].toString());
        currComponent.ProductionParent = parentObject;
        components.add(currComponent);
      });
    }
    this.isPrepared = true;
  }
}
