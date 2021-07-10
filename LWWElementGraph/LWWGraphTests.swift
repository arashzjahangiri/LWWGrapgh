//
//  LWWGraphTests.swift
//  graphGraph
//
//  Created by Arash Z. Jahangiri on 02.07.21.
//

import Foundation

struct LWWGraphTests {
    func startTests() {
        var graph = LWWGraph<String>()
        let timeStamp: Double = 1
        
        graph.add(vertex: "A", timeStamp: 1)
        
        // Test1 expect the returned value is as same as given value.
        let addAddHashList = graph.getAddVertexHashList()
        assert(addAddHashList["A"] == timeStamp, "expect the returned value is as same as given value")

        // Test2 checkExistence for a vertex not added in list.
        assert(graph.checkVertexExistence("B") == false, "should returns false when we don't have such a vertex")

        // Test3 checkExistence for a vertex added in Add-list.
        assert(graph.checkVertexExistence("A") == true, "should returns true when vertex was already in list")

        // Test4 checkExistence for a remove-operation with a higher time stamp than it was added to list.
        assert(graph.remove(vertex: "A", timeStamp: timeStamp + 1) == true, "should returns true, because operation was successful.")
        assert(graph.checkVertexExistence("A") == false, "should returns false when it was added in remove-list with a higher time stamp than add-list")

        // Test5 remove a vertex which it's not exist in list.
        assert(graph.remove(vertex: "A", timeStamp: timeStamp + 1) == false, "should returns false, because such element does not exist in list")

        // Test6 adding to edge-list when one of two vertex does not exist in list.
        assert(graph.addEdge(between: "A", and: "B", timeStamp: timeStamp) == false, "can not create edge between two vertices, one of two does not exist in list")

        // Test7 adding to edge-list is failed, when both vertices exist in list but one of them has earlier time stamp in compare to it's twins in remove-list.
        graph.add(vertex: "B", timeStamp: timeStamp)
        assert(graph.addEdge(between: "A", and: "B", timeStamp: timeStamp) == false, "The operation is failed, although two vertices are exist in list, but vertex A has added already in remove-list with higher time stamp.")

        // Test8 adding to edge-list is successful, because both vertices exist in list.
        graph.add(vertex: "A", timeStamp: timeStamp + 2)
        graph.add(vertex: "B", timeStamp: timeStamp)
        assert(graph.addEdge(between: "A", and: "B", timeStamp: timeStamp) == true, "The operation is failed, although two vertices are exist in list, but vertex A has added already in remove-list with higher time stamp.")

        // Test9 removing vertex A when there is an edge like `A-B` should returns false.
        assert(graph.remove(vertex: "A", timeStamp: timeStamp + 3) == false, "should returns false.")

        // Test10 check remove of an edge which it doesn't exist in edge-list.
        assert(graph.remove(edge: ["A", "C"], timeStamp: timeStamp) == false, "should returns false.")

        // Test11 check remove of an edge which it exist in edge-list.
        assert(graph.remove(edge: ["A", "B"], timeStamp: timeStamp + 1) == true, "should returns true.")

        // Test12 get all connected vertices for vertex `A`
        graph.add(vertex: "C", timeStamp: timeStamp + 4)
        graph.add(vertex: "D", timeStamp: timeStamp + 5)
        graph.add(vertex: "E", timeStamp: timeStamp + 6)
        graph.add(vertex: "F", timeStamp: timeStamp + 7)
        graph.add(vertex: "G", timeStamp: timeStamp + 8)
        let _ = graph.addEdge(between: "A", and: "B", timeStamp: timeStamp + 9)
        assert(graph.getListOfConnectedVertices(for: "A")?.count == 1, "Should returns 1, while we have 2 edges like `A-B`")

        // Test13 get path between `A` and `B`.
        let _ = graph.addEdge(between: "B", and: "C", timeStamp: timeStamp + 9)
        let _ = graph.addEdge(between: "C", and: "D", timeStamp: timeStamp + 10)
        let _ = graph.addEdge(between: "D", and: "E", timeStamp: timeStamp + 11)
        let _ = graph.addEdge(between: "D", and: "G", timeStamp: timeStamp + 12)
        let _ = graph.addEdge(between: "D", and: "E", timeStamp: timeStamp + 13)

        let (A_B_list, A_B_result) = graph.findPath(between: "A", and: "B")
        assert(A_B_list == ["A", "B"], "Should returns one item like [A, B]")
        assert(A_B_result == true, "Should returns true")

        // Test14 get path between `A` and `C`.
        let (A_C_list, A_C_result) = graph.findPath(between: "A", and: "C")
        assert(A_C_list == ["A", "B", "C"], "Should be equal")
        assert(A_C_result == true, "Should returns true")

        // Test15 get path between `A` and `D`.
        let (A_D_list, A_D_result) = graph.findPath(between: "A", and: "D")
        assert(A_D_list == ["A", "B", "C", "D"], "Should be equal")
        assert(A_D_result == true, "Should returns true")

        // Test16 get path between `A` and `E`.
        let (A_E_list, A_E_result) = graph.findPath(between: "A", and: "E")
        assert(A_E_list == ["A", "B", "C", "D", "E"], "Should be equal")
        assert(A_E_result == true, "Should returns true")

        // Test17 get path between `A` and `F`.
        let (A_F_list, A_F_result) = graph.findPath(between: "A", and: "F")
        assert(A_F_list == nil, "Should be nil")
        assert(A_F_result == false, "Should returns false")

        // Test18 get path between `A` and `G`.
        let (A_G_list, A_G_result) = graph.findPath(between: "A", and: "G")
        assert(A_G_list == ["A", "B", "C", "D", "G"], "Should be equal")
        assert(A_G_result == true, "Should returns true")

        // Test19 get path between `E` and `G`.
        let (E_G_list, E_G_result) = graph.findPath(between: "E", and: "G")
        assert(E_G_list == ["E", "D", "G"], "Should be equal")
        assert(E_G_result == true, "Should returns true")

        // Test20 get path between `E` and `A`.
        let (E_A_list, E_A_result) = graph.findPath(between: "E", and: "A")
        assert(E_A_list == nil, "Should be nil")
        assert(E_A_result == false, "Should returns false")

        // Test21 merge
        var graph1 = LWWGraph<Int>()
        graph1.add(vertex: 1, timeStamp: 1)
        graph1.add(vertex: 2, timeStamp: 1)

        var graph2 = LWWGraph<Int>()
        graph2.add(vertex: 2, timeStamp: 2)
        graph2.add(vertex: 3, timeStamp: 2)

        graph1.mergeGraph(with: graph2)
        assert(graph1.getAddVertexHashList().count == 3, "If merging we will have 3 key-pairs")
        assert((graph1.getAddVertexHashList()[1] == 1), "value for key 1 should be equal to 1")
        assert((graph1.getAddVertexHashList()[2] == 2), "value for key 2 should be equal to 2")
        assert((graph1.getAddVertexHashList()[3] == 2), "value for key 3 should be equal to 2")

        print("All tests of LWWGraph Done!")
    }
}
