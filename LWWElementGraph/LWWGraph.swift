//
//  LWWGraph.swift
//  LWWElementGraph
//
//  Created by Arash Z. Jahangiri on 30.06.21.
//

import Foundation

/*
 - add a vertex/edge
 - remove a vertex/edge
 - check if a vertex is in the graph
 - query for all vertices connected to a vertex
 - find any path between two vertices
 - merge with concurrent changes from other graph/replica.
 */

protocol LWWGraphProtocol {
    associatedtype T: Hashable, Comparable
    
    mutating func add(vertex: T, timeStamp: Double)
    mutating func addEdge(between vertex1: T, and vertex2: T, timeStamp: Double) -> Bool
    mutating func remove(vertex: T, timeStamp: Double) -> Bool
    mutating func remove(edge: [T], timeStamp: Double) -> Bool
    func checkVertexExistence(_ vertex: T) -> Bool
    func getListOfConnectedVertices(for vertex: T) -> [T]?
    func findPath(between vertex1: T, and vertex2: T) -> ([T]?, Bool)
    mutating func mergeGraph(with anotherGraph: Self)
}

struct LWWGraph<T: Hashable>: LWWGraphProtocol where T: Comparable {
    var lww = LWWElement<T>()
    var timeStamp: Double {
        NSDate().timeIntervalSince1970
    }
    
    mutating func add(vertex: T, timeStamp: Double) {
        lww.add(vertex: vertex, timeStamp: timeStamp)
    }
    
    mutating func remove(vertex: T, timeStamp: Double) -> Bool {
        return lww.remove(vertex: vertex, timeStamp: timeStamp)
    }
    
    mutating func addEdge(between vertex1: T, and vertex2: T, timeStamp: Double) -> Bool {
        return lww.addEdge(between: vertex1, and: vertex2, timeStamp: timeStamp)
    }
    
    mutating func remove(edge: [T], timeStamp: Double) -> Bool {
        return lww.remove(edge: edge, timeStamp: timeStamp)
    }
    
    func checkVertexExistence(_ vertex: T) -> Bool {
        return lww.checkVertexExistence(vertex)
    }
    
    func getListOfConnectedVertices(for vertex: T) -> [T]? {
        return lww.queryAllConnectedVertices(to: vertex)
    }
    
    mutating func mergeGraph(with anotherGraph: LWWGraph) {
        lww.merge(with: anotherGraph.lww)
    }
    
    func getGraph() {
        var graph: [T: [T]] = [:]
        for vertex in lww.getAddVertexHashList() {
            if checkVertexExistence(vertex as! T) {
                let connections = lww.queryAllConnectedVertices(to: vertex as! T)
                graph[vertex as! T] = connections
            }
        }
    }
    
    func findPath(between vertex1: T, and vertex2: T) -> ([T]?, Bool) {
        return lww.findPath(between: vertex1, and: vertex2)
    }
    
    func getAddVertexHashList() -> [T: Double] {
        return lww.addVertexHashList
    }
    func getRemoveVertexHashList() -> [T: Double] {
        return lww.removeVertexHashList
    }
    
    func getAddEdgeHashList() -> [[T]: Double] {
        return lww.addEdgeHashList
    }
    func getRemoveEdgeHashList() -> [[T]: Double] {
        return lww.removeEdgeHashList
    }
}
