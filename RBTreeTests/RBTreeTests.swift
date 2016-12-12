//
//  RBTreeTests.swift
//  RBTreeTests
//
//  Created by Wenbin Zhang on 12/9/16.
//  Copyright © 2016 Wenbin Zhang. All rights reserved.
//

import XCTest
@testable import RBTree

class RBTreeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLeftRotation_rootNode() {
        let tree = RBTree<Int>()
        tree.root = RBTreeNode(value: 5)
        tree.rotateLeft(tree.root!)
        XCTAssertEqual(tree.root?.value, 5)
        let newNode = RBTreeNode(value: 3)
        tree.root?.leftChild = newNode
        newNode.parent = tree.root
        tree.rotateRight(newNode)
        XCTAssertEqual(tree.root, newNode)
    }

    func testLeftRotation_multipleNodes() {
        let tree = RBTree<Int>()
        let originRoot = RBTreeNode(value: 1)
        tree.root = originRoot
        let left = RBTreeNode(value: 2)
        let right = RBTreeNode(value: 3)
        let leftLeft = RBTreeNode(value: 4)
        let leftRight = RBTreeNode(value: 5)
        tree.root?.leftChild = left
        left.parent = tree.root
        tree.root?.rightChild = right
        right.parent = tree.root
        tree.root?.leftChild?.leftChild = leftLeft
        leftLeft.parent = tree.root?.leftChild
        tree.root?.leftChild?.rightChild = leftRight
        leftRight.parent = tree.root?.leftChild
        tree.rotateRight(tree.root!.leftChild!)
        XCTAssertEqual(tree.root, left)
        XCTAssertEqual(tree.root?.leftChild, leftLeft)
        XCTAssertEqual(tree.root?.rightChild, originRoot)
        XCTAssertEqual(tree.root?.rightChild?.leftChild, leftRight)
    }

    func testInsert() {
        let tree = RBTree<Int>()
        tree.insert(value: 1)
        XCTAssertNotNil(tree.root)
        XCTAssertEqual(tree.root?.value, 1)
        XCTAssertEqual(tree.root?.color, .BLACK)

        tree.insert(value: 2)
        XCTAssertNotNil(tree.root?.rightChild)
        XCTAssertNil(tree.root?.leftChild)
        XCTAssertEqual(tree.root?.rightChild?.value, 2)
        XCTAssertEqual(tree.root?.rightChild?.color, .RED)

        tree.insert(value: 3)
        XCTAssertEqual(tree.root?.value, 2)
        XCTAssertEqual(tree.root?.color, .BLACK)
        XCTAssertEqual(tree.root?.leftChild?.value, 1)
        XCTAssertEqual(tree.root?.leftChild?.color, .RED)
        XCTAssertEqual(tree.root?.rightChild?.color, .RED)
        XCTAssertEqual(tree.root?.rightChild?.value, 3)

        tree.insert(value: 4)
        XCTAssertEqual(tree.root?.value, 2)
        XCTAssertEqual(tree.root?.color, .BLACK)
        XCTAssertEqual(tree.root?.leftChild?.value, 1)
        XCTAssertEqual(tree.root?.leftChild?.color, .BLACK)
        XCTAssertEqual(tree.root?.rightChild?.color, .BLACK)
        XCTAssertEqual(tree.root?.rightChild?.value, 3)
        XCTAssertEqual(tree.root?.rightChild?.rightChild?.value, 4)
        XCTAssertEqual(tree.root?.rightChild?.rightChild?.color, .RED)
        XCTAssertNil(tree.root?.rightChild?.leftChild)

        tree.insert(value: 8)
        XCTAssertEqual(tree.root?.value, 2)
        XCTAssertEqual(tree.root?.rightChild?.value, 4)
        XCTAssertEqual(tree.root?.rightChild?.leftChild?.value, 3)
        XCTAssertEqual(tree.root?.rightChild?.rightChild?.value, 8)
        XCTAssertEqual(tree.root?.rightChild?.color, .BLACK)
        XCTAssertEqual(tree.root?.rightChild?.leftChild?.color, .RED)

        tree.insert(value: 6)
        XCTAssertEqual(tree.root?.value, 2)
        XCTAssertEqual(tree.root?.leftChild?.value, 1)
        XCTAssertEqual(tree.root?.leftChild?.color, .BLACK)
        XCTAssertEqual(tree.root?.rightChild?.value, 4)
        XCTAssertEqual(tree.root?.rightChild?.leftChild?.value, 3)
        XCTAssertEqual(tree.root?.rightChild?.rightChild?.value, 8)
        XCTAssertEqual(tree.root?.color, .BLACK)
        XCTAssertEqual(tree.root?.rightChild?.color, .RED)
        XCTAssertEqual(tree.root?.rightChild?.leftChild?.color, .BLACK)
        XCTAssertEqual(tree.root?.rightChild?.rightChild?.color, .BLACK)
    }
}
