//
//  LWWElementTests.swift
//  LWWElementGraph
//
//  Created by Arash Z. Jahangiri on 02.07.21.
//

import Foundation

struct LWWElementsTests {
    func startTests() {
        var lwwElement = LWWElement<String>()
        let timeStamp: Double = 123
        lwwElement.add(vertex: "A", timeStamp: timeStamp)

        // Test1 expect the returned value is as same as given value.
        let addAddHashList = lwwElement.getAddVertexHashList()
        assert(addAddHashList["A"] == timeStamp, "expect the returned value is as same as given value")

        // Test2 checkExistence for a vertex not added in list.
        assert(lwwElement.checkVertexExistence("B") == false, "should returns false when we don't have such a vertex")

        // Test3 checkExistence for a vertex added in Add-list.
        assert(lwwElement.checkVertexExistence("A") == true, "should returns true when vertex was already in list")

        // Test4 checkExistence for a remove-operation with a higher time stamp than it was added to list.
        assert(lwwElement.remove(vertex: "A", timeStamp: timeStamp + 1) == true, "should returns true, because operation was successful.")
        assert(lwwElement.checkVertexExistence("A") == false, "should returns false when it was added in remove-list with a higher time stamp than add-list")

        // Test5 remove a vertex which it's not exist in list.
        assert(lwwElement.remove(vertex: "A", timeStamp: timeStamp + 1) == false, "should returns false, because such element does not exist in list")

        // Test6 adding to edge-list when one of two vertex does not exist in list.
        assert(lwwElement.addEdge(between: "A", and: "B", timeStamp: timeStamp) == false, "can not create edge between two vertices, one of two does not exist in list")

        // Test7 adding to edge-list is failed, when both vertices exist in list but one of them has earlier time stamp in compare to it's twins in remove-list.
        lwwElement.add(vertex: "B", timeStamp: timeStamp)
        assert(lwwElement.addEdge(between: "A", and: "B", timeStamp: timeStamp) == false, "The operation is failed, although two vertices are exist in list, but vertex A has added already in remove-list with higher time stamp.")

        // Test8 adding to edge-list is successful, because both vertices exist in list.
        lwwElement.add(vertex: "A", timeStamp: timeStamp + 2)
        lwwElement.add(vertex: "B", timeStamp: timeStamp)
        assert(lwwElement.addEdge(between: "A", and: "B", timeStamp: timeStamp) == true, "The operation is failed, although two vertices are exist in list, but vertex A has added already in remove-list with higher time stamp.")

        // Test9 testing isVertexInEdge for a edge `A-B`
        assert(lwwElement.isVertexInEdge("A") == true, "should returns true.")

        // Test10 removing vertex A when there is an edge like `A-B` should returns false.
        assert(lwwElement.remove(vertex: "A", timeStamp: timeStamp + 3) == false, "should returns false.")

        // Test11 check existence of an edge which it does not exist is edge-list.
        assert(lwwElement.checkEdgeExistence(["A", "C"]) == false, "should returns false, because edge does not exist is edge-list.")

        // Test12 check existence of an edge which it exist in edge-list.
        assert(lwwElement.checkEdgeExistence(["A", "B"]) == true, "should returns true.")

        // Test13 check remove of an edge which it doesn't exist in edge-list.
        assert(lwwElement.remove(edge: ["A", "C"], timeStamp: timeStamp) == false, "should returns false.")

        // Test14 check remove of an edge which it exist in edge-list.
        assert(lwwElement.remove(edge: ["A", "B"], timeStamp: timeStamp + 1) == true, "should returns true.")

        // Test15 check existence of a removed-edge.
        assert(lwwElement.checkEdgeExistence(["A", "B"]) == false, "should returns false.")

        // Test16 get all connected vertices for vertex `A`
        lwwElement.add(vertex: "C", timeStamp: timeStamp + 4)
        lwwElement.add(vertex: "D", timeStamp: timeStamp + 5)
        lwwElement.add(vertex: "E", timeStamp: timeStamp + 6)
        lwwElement.add(vertex: "F", timeStamp: timeStamp + 7)
        lwwElement.add(vertex: "G", timeStamp: timeStamp + 8)
        let _ = lwwElement.addEdge(between: "A", and: "B", timeStamp: timeStamp + 9)
        assert(lwwElement.queryAllConnectedVertices(to: "A")?.count == 1, "Should returns 1, while we have 2 edges like `A-B`")

        // Test17 get path between `A` and `B`.
        let _ = lwwElement.addEdge(between: "B", and: "C", timeStamp: timeStamp + 9)
        let _ = lwwElement.addEdge(between: "C", and: "D", timeStamp: timeStamp + 10)
        let _ = lwwElement.addEdge(between: "D", and: "E", timeStamp: timeStamp + 11)
        let _ = lwwElement.addEdge(between: "D", and: "G", timeStamp: timeStamp + 12)
        let _ = lwwElement.addEdge(between: "D", and: "E", timeStamp: timeStamp + 13)

        let (A_B_list, A_B_result) = lwwElement.findPath(between: "A", and: "B")
        assert(A_B_list == ["A", "B"], "Should returns one item like [A, B]")
        assert(A_B_result == true, "Should returns true")

        // Test18 get path between `A` and `C`.
        let (A_C_list, A_C_result) = lwwElement.findPath(between: "A", and: "C")
        assert(A_C_list == ["A", "B", "C"], "Should be equal")
        assert(A_C_result == true, "Should returns true")

        // Test19 get path between `A` and `D`.
        let (A_D_list, A_D_result) = lwwElement.findPath(between: "A", and: "D")
        assert(A_D_list == ["A", "B", "C", "D"], "Should be equal")
        assert(A_D_result == true, "Should returns true")

        // Test20 get path between `A` and `E`.
        let (A_E_list, A_E_result) = lwwElement.findPath(between: "A", and: "E")
        assert(A_E_list == ["A", "B", "C", "D", "E"], "Should be equal")
        assert(A_E_result == true, "Should returns true")

        // Test21 get path between `A` and `F`.
        let (A_F_list, A_F_result) = lwwElement.findPath(between: "A", and: "F")
        assert(A_F_list == nil, "Should be nil")
        assert(A_F_result == false, "Should returns false")

        // Test22 get path between `A` and `G`.
        let (A_G_list, A_G_result) = lwwElement.findPath(between: "A", and: "G")
        assert(A_G_list == ["A", "B", "C", "D", "G"], "Should be equal")
        assert(A_G_result == true, "Should returns true")

        // Test23 get path between `E` and `G`.
        let (E_G_list, E_G_result) = lwwElement.findPath(between: "E", and: "G")
        assert(E_G_list == ["E", "D", "G"], "Should be equal")
        assert(E_G_result == true, "Should returns true")

        // Test24 get path between `E` and `A`.
        let (E_A_list, E_A_result) = lwwElement.findPath(between: "E", and: "A")
        assert(E_A_list == nil, "Should be nil")
        assert(E_A_result == false, "Should returns false")

        // Test25 merge
        var lww1 = LWWElement<Int>()
        lww1.add(vertex: 1, timeStamp: 1)
        lww1.add(vertex: 2, timeStamp: 1)

        var lww2 = LWWElement<Int>()
        lww2.add(vertex: 2, timeStamp: 2)
        lww2.add(vertex: 3, timeStamp: 2)

        lww1.merge(with: lww2)
        assert(lww1.getAddVertexHashList().count == 3, "If merging we will have 3 key-pairs")
        assert((lww1.getAddVertexHashList()[1] == 1), "value for key 1 should be equal to 1")
        assert((lww1.getAddVertexHashList()[2] == 2), "value for key 2 should be equal to 2")
        assert((lww1.getAddVertexHashList()[3] == 2), "value for key 3 should be equal to 2")

        print("All tests of LWWElements Done!")
    }
}
