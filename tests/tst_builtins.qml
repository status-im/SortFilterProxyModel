import QtQuick 2.0
import QtQml 2.2
import QtTest 1.1
import SortFilterProxyModel 0.2

Item {
    ListModel {
        id: testModel
        ListElement{role1: 1; role2: 1}
        ListElement{role1: 2; role2: 1}
        ListElement{role1: 3; role2: 2}
        ListElement{role1: 4; role2: 2}
    }
    ListModel {
        id: noRolesFirstTestModel_1
        function initModel() {
            append({role1: 1, role2: 1 })
            append({role1: 2, role2: 1 })
            append({role1: 3, role2: 2 })
            append({role1: 4, role2: 2 })
        }
    }
    ListModel {
        id: noRolesFirstTestModel_2
        function initModel() {
            append({role1: 3, role2: 2 })
            append({role1: 4, role2: 2 })
        }
    }
    ListModel {
        id: noRolesFirstTestModel_3
        function initModel() {
            append({role1: 3, role2: 2 })
            append({role1: 4, role2: 2 })
        }
    }
    SortFilterProxyModel {
        id: testProxyModel
        property string tag: "testProxyModel"
        sourceModel: testModel
        filterRoleName: "role2"
        filterValue: 2
        property var expectedData: ([{role1: 3, role2: 2}, {role1: 4, role2: 2}])
    }
    SortFilterProxyModel {
        id: noRolesFirstTestProxyModel
        property string tag: "noRolesFirstTestProxyModel"
        sourceModel: noRolesFirstTestModel_1
        filterRoleName: "role2"
        filterValue: 2
        property var expectedData: ([{role1: 3, role2: 2}, {role1: 4, role2: 2}])
    }
    SortFilterProxyModel {
        id: noRolesFirstTestProxyModelWithProxyRoles
        property string tag: "noRolesFirstTestProxyModelWithProxyRoles"
        sourceModel: noRolesFirstTestModel_2
        property var expectedData: ([{role1: 3, role2: 2, proxyRole: 42}, {role1: 4, role2: 2, proxyRole: 42}])

        proxyRoles: ExpressionRole {
            name: "proxyRole"
            expression: 42
        }
    }
    SortFilterProxyModel {
        id: noRolesFirstTestProxyModelWithProxyRolesNested
        property string tag: "noRolesFirstTestProxyModelWithProxyRolesNested"

        property var nested: SortFilterProxyModel {
            id: nested

            function initModel() {
                sourceModel.initModel();
            }

            sourceModel: noRolesFirstTestModel_3

            proxyRoles: ExpressionRole {
                name: "proxyRole"
                expression: 42
            }
        }

        sourceModel: nested
        property var expectedData: ([{role1: 3, role2: 2, proxyRole: 42}, {role1: 4, role2: 2, proxyRole: 42}])
    }
    TestCase {
        name: "BuiltinsFilterTests"
        function test_filterValue_data() {
            return [testProxyModel, noRolesFirstTestProxyModel,
                    noRolesFirstTestProxyModelWithProxyRoles,
                    noRolesFirstTestProxyModelWithProxyRolesNested];
        }

        function test_filterValue(proxyModel) {
            if (proxyModel.sourceModel.initModel)
                proxyModel.sourceModel.initModel()
            var data = [];
            for (var i = 0; i < proxyModel.count; i++)
                data.push(proxyModel.get(i));

            compare(data, proxyModel.expectedData);
        }
    }
}
