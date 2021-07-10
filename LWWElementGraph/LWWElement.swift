//
//  LWWItem.swift
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

protocol LWWElementProtocol {
    associatedtype T: Hashable, Comparable
    
    mutating func add(vertex: T, timeStamp: Double)
    mutating func addEdge(between vertex1: T, and vertex2: T, timeStamp: Double) -> Bool
    mutating func remove(vertex: T, timeStamp: Double) -> Bool
    mutating func remove(edge: [T], timeStamp: Double) -> Bool
    func checkVertexExistence(_ vertex: T) -> Bool
    func queryAllConnectedVertices(to vertex: T) -> [T]?
    func findPath(between vertex1: T, and vertex2: T) -> ([T]?, Bool)
    mutating func merge(with anotherLWW: Self)
}

struct LWWElement<T: Hashable>: LWWElementProtocol where T: Comparable {
    
    private(set) var addVertexHashList: [T: Double] = [:]
    private(set) var removeVertexHashList: [T: Double] = [:]
    private(set) var addEdgeHashList: [[T]: Double] = [:]
    private(set) var removeEdgeHashList: [[T]: Double] = [:]

    /// Adds a vertex to list.
    ///
    /// - Parameters:
    ///   - vertex: of type T
    ///   - timestamp: Double
    mutating func add(vertex: T, timeStamp: Double) {
        addVertexHashList[vertex] = timeStamp
    }
    
    /// Removes a vertex from list logically. Actually it will be add it to removed-list.
    ///
    /// - Parameters:
    ///   - vertex: of type T
    ///   - timestamp: Double
    /// - Returns: Result of operation in Boolean type.
    mutating func remove(vertex: T, timeStamp: Double) -> Bool {
        if checkVertexExistence(vertex) {
            if !isVertexInEdge(vertex) {
                removeVertexHashList[vertex] = timeStamp
                return true
            }
        }
        return false
    }
    
    /// Checks whether the given vertex exist
    ///
    /// - Parameters:
    ///   - vertex: of type T
    /// - Returns: Result of operation in Boolean type.
    func checkVertexExistence(_ vertex: T) -> Bool {
        if let removeTimeStamp = removeVertexHashList[vertex], let addTimeStamp = addVertexHashList[vertex] {
            return addTimeStamp > removeTimeStamp
        } else if addVertexHashList[vertex] != nil && removeVertexHashList[vertex] == nil {
            return true
        }
        
        return false
    }
    
    /// Checks wether the given vertex is in used by an edge.
    ///
    /// - Parameters:
    ///   - vertex: of type T
    /// - Returns: Result of operation in Boolean type.
    func isVertexInEdge(_ vertex: T) -> Bool {
        for edge in addEdgeHashList {
            if checkVertexExistence(vertex) {
                if edge.key.contains(vertex) {
                    return true
                }
            }
        }
        return false
    }
    
    /// Removes a vertex from list logically. Actually it will be add it to removed-list.
    ///
    /// - Parameters:
    ///   - vertex1: of type T
    ///   - vertex2: of type T
    ///   - timestamp: Double
    /// - Returns: Result of operation in Boolean type.
    mutating func addEdge(between vertex1: T, and vertex2: T, timeStamp: Double) -> Bool {
        if checkVertexExistence(vertex1) && checkVertexExistence(vertex2) {
            addEdgeHashList[[vertex1, vertex2]] = timeStamp
            return true
        }
        return false
    }
    
    /// Checks wether the given edge is exist.
    ///
    /// - Parameters:
    ///   - edge: of type [T]
    /// - Returns: Result of operation in Boolean type.
    func checkEdgeExistence(_ edge: [T]) -> Bool {
        guard checkVertexExistence(edge[0]) &&
                checkVertexExistence(edge[1]) &&
                addEdgeHashList.keys.contains(edge) else { return false}
        let addTimeStamp = addEdgeHashList[edge] ?? 0
        let removeTimeStamp = removeEdgeHashList[edge] ?? 0
        if removeEdgeHashList.keys.contains(edge) {
            return addTimeStamp > removeTimeStamp
        } else {
            return true
        }
    }
    
    /// Removes given edge.
    ///
    /// - Parameters:
    ///   - edge: of type [T]
    ///   - timestamp: Double
    /// - Returns: Result of operation in Boolean type.
    mutating func remove(edge: [T], timeStamp: Double) -> Bool {
        if checkEdgeExistence(edge) {
            removeEdgeHashList[edge] = timeStamp
            return true
        }
        return false
    }
    
    /// Returns list of all connected vertices for a given vertex.
    ///
    /// - Parameters:
    ///   - vertex1: of type T
    /// - Returns: list of all connected vertices of type  or nil if it couldn't find anything.
    func queryAllConnectedVertices(to vertex: T) -> [T]? {
        var connectedVertices = [T]()
        for edge in addEdgeHashList {
            if checkVertexExistence(vertex) {
                let vertices = edge.key
                if vertices[0] == vertex {
                    connectedVertices.append(vertices[1])
                } else if vertices[1] == vertex {
                    connectedVertices.append(vertices[0])
                }
            }
        }
        return connectedVertices
    }
    
    /// Merges another LWWElement with current LWWElement.
    ///
    /// - Parameters:
    ///   - LWWElement
    mutating func merge(with anotherLWW: LWWElement) {
        addVertexHashList.merge(dict: anotherLWW.addVertexHashList)
        removeVertexHashList.merge(dict: anotherLWW.removeVertexHashList)
        addEdgeHashList.merge(dict: anotherLWW.addEdgeHashList)
        removeEdgeHashList.merge(dict: anotherLWW.removeEdgeHashList)
    }
    
    /// Returns all vertices which added into LWWElement.
    ///
    /// - Returns: all vertices which added into LWWElement.
    func getAddVertexHashList() -> [T: Double] {
        return addVertexHashList
    }
    
    /// Returns all vertices which removed into LWWElement.
    ///
    /// - Returns: all vertices which removed into LWWElement.
    func getRemoveVertexHashList() -> [T: Double] {
        return removeVertexHashList
    }
    
    /// Returns all edges which created into LWWElement.
    ///
    /// - Returns: all edges which created into LWWElement.
    func getAddEdgeHashList() -> [[T]: Double] {
        return addEdgeHashList
    }
    
    /// Returns all edges which removed from LWWElement.
    ///
    /// - Returns: all edges which removed from LWWElement.
    func getRemoveEdgeHashList() -> [[T]: Double] {
        return removeEdgeHashList
    }
    
    /// Finds one path between two given vertices.
    ///
    /// - Parameters:
    ///   - vertex1: of type T
    ///   - vertex2: of type T
    /// - Returns: Path between two given vertices or nil if there isn't any path between them.
    func findPath(between vertex1: T, and vertex2: T) -> ([T]?, Bool) {
        guard checkVertexExistence(vertex1) && checkVertexExistence(vertex2) else { return (nil, false) }
        var visitedList = [T]()
        if checkEdgeExistence([vertex1, vertex2]) {
            if let _ = addEdgeHashList[[vertex1, vertex2]] {
                visitedList.append(vertex1)
                visitedList.append(vertex2)
                return (visitedList, true)
            }
        }
        
        guard let vertex1Neighbours = queryAllConnectedVertices(to: vertex1) else { return (nil, false) }
        var nextVertex = vertex1
        if let lastItem = vertex1Neighbours.last {
            nextVertex = lastItem
        }
        visitedList.append(vertex1)
        visitedList.append(nextVertex)
        var numberOfTry = 0
        while visitedList.count < getAddVertexHashList().count {
            guard let neighboursOfNextVertex = queryAllConnectedVertices(to: nextVertex) else { return (nil, false) }
            let sortedNeighbours = neighboursOfNextVertex.sorted { $0 < $1 }
            if sortedNeighbours.contains(vertex2) {
                visitedList.append(sortedNeighbours[sortedNeighbours.firstIndex(of: vertex2)!])
                return (visitedList, true)
            }
            for item in sortedNeighbours {
                if !visitedList.contains(item) && checkEdgeExistence([nextVertex, item]) {
                    visitedList.append(item)
                    nextVertex = visitedList.last!
                    if item == vertex2 {
                        return (visitedList, true)
                    }
                }
            }
            numberOfTry += 1
            if numberOfTry > visitedList.count {
                break
            }
        }
        return (nil, false)
    }
}

extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (key, value) in dict {
            updateValue(value, forKey: key)
        }
    }
}
