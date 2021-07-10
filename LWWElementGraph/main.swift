//
//  main.swift
//  LWWElementGraph
//
//  Created by Arash Z. Jahangiri on 30.06.21.
//

/*
 - add a vertex/edge
 - remove a vertex/edge
 - check if a vertex is in the graph
 - query for all vertices connected to a vertex
 - find any path between two vertices
 - merge with concurrent changes from other graph/replica.
 */
import Foundation

let lwwElementTests = LWWElementsTests()
lwwElementTests.startTests()

let lwwGraphTests = LWWGraphTests()
lwwGraphTests.startTests()
