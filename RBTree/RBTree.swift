//
//  RBTree.swift
//  RBTree
//
//  Created by Wenbin Zhang on 12/9/16.
//  Copyright © 2016 Wenbin Zhang. All rights reserved.
//

import Foundation

enum NodeColor {
    case RED, BLACK
}

protocol BinaryTreeNodeType : class, Equatable {
    associatedtype ValueType: Comparable
    var value: ValueType { get set }
    var leftChild: Self? { get set }
    var rightChild: Self? { get set }
    weak var parent: Self? { get set }

    init(value: ValueType)
}

enum BalanceRotateOperationCase {
    case NoOperation, LeftLeft, LeftRight, RightLeft, RightRight

    static func of<Node : BinaryTreeNodeType>(_ node: Node) -> BalanceRotateOperationCase {
        guard let nodeParent = node.parent, let grandParent = nodeParent.parent else {
            return .NoOperation
        }

        if nodeParent.leftChild == node {
            return grandParent.leftChild == nodeParent ? .LeftLeft : .RightLeft
        } else if nodeParent.rightChild == node {
            return grandParent.leftChild == nodeParent ? .LeftRight : .RightRight
        }
        return .NoOperation
    }
}

///Red black tree node.
/// - Parameters:
///     - value: The value stored in the node. value must conform to Equatable
///     - parent: The parent of the current node. Nil if this is the root
///     - leftChild: The left child node.
///     - rightChild: The right child node.
final class RBTreeNode<T> : BinaryTreeNodeType where T: Comparable {
    typealias ValueType = T
    var value: ValueType
    weak var parent: RBTreeNode<ValueType>?
    var leftChild: RBTreeNode<ValueType>?
    var rightChild: RBTreeNode<ValueType>?
    var color: NodeColor = .RED

    required init(value: ValueType) {
        self.value = value
    }
}

func ==<T: Comparable> (lhs: RBTreeNode<T>, rhs: RBTreeNode<T>) -> Bool {
    let equals = lhs.value == rhs.value
        && lhs.parent === rhs.parent
        && lhs.leftChild === rhs.leftChild
        && lhs.rightChild === rhs.rightChild
        && lhs.color == rhs.color
    return equals
}

protocol BinarySearchTreeType: class {
    associatedtype Node : BinaryTreeNodeType
    var root: Node? {get set}

    func insert(_ newNode: Node, after: (_ node: Node, _ isRoot: Bool) -> Void) -> Self
    func delete(_ node: Node) throws
}

extension BinarySearchTreeType {
    func insert(_ newNode: Node, after: (_ node: Node, _ isRoot: Bool) -> Void) -> Self {
        guard let notNilRoot = root else {
            root = newNode
            after(newNode, true)
            return self
        }
        var parent = notNilRoot
        var currentNode: Node? = notNilRoot
        while true {
            guard let notNilCurrentNode = currentNode else {
                break
            }
            parent = notNilCurrentNode
            if newNode.value < notNilCurrentNode.value {
                currentNode = notNilCurrentNode.leftChild
            } else {
                currentNode = notNilCurrentNode.rightChild
            }
        }
        if newNode.value < parent.value {
            parent.leftChild = newNode
        } else {
            parent.rightChild = newNode
        }
        newNode.parent = parent
        after(newNode, false)
        return self
    }

    func delete(_ node: Node) {}
}

extension BinarySearchTreeType {
    func rotateLeft(_ node: Node) {
        guard let notNilParent = node.parent else {
            return;
        }
        guard notNilParent.rightChild == node else {
            return;
        }
        node.parent = notNilParent.parent
        let leftChild = node.leftChild
        notNilParent.rightChild = leftChild
        node.leftChild = notNilParent
        notNilParent.parent = node
        guard let newParent = node.parent else {
            root = node
            return
        }
        if newParent.leftChild == notNilParent {
            newParent.leftChild = node
        } else if newParent.rightChild == notNilParent {
            newParent.rightChild = node
        }
    }

    func rotateRight(_ node: Node) {
        guard let notNilParent = node.parent else {
            return;
        }
        guard notNilParent.leftChild == node else {
            return;
        }
        node.parent = notNilParent.parent
        let rightChild = node.rightChild
        notNilParent.leftChild = rightChild
        node.rightChild = notNilParent
        notNilParent.parent = node
        guard let newParent = node.parent else {
            root = node
            return
        }
        if newParent.leftChild == notNilParent {
            newParent.leftChild = node
        } else if newParent.rightChild == notNilParent {
            newParent.rightChild = node
        }
    }
}

/// **Red-Black Tree definition:**
/// 1. Every node has color: RED or BLACK
/// 2. Root node is BLACK, Nil node is BLACK
/// 3. RED node's parent and children must be BLACK
/// 4. Any paths from node to its leaves must have the same number of black nodes.
public final class RBTree<T> : BinarySearchTreeType where T: Comparable {
    var root: RBTreeNode<T>?

    func insert(value: T) {
        let newNode = createNewNodeFor(value)
        insert(newNode, after: {(node, isRoot) -> Void in
            if isRoot {
                node.color = .BLACK
            }
        }).fixTreeAfterInsertIfNeeded(at: newNode)
    }

    private func createNewNodeFor(_ value: T) -> RBTreeNode<T> {
        return RBTreeNode(value: value)
    }
}

/// Tree maintaince operations
extension RBTree {
    fileprivate func fixTreeAfterInsertIfNeeded(at node: RBTreeNode<T>) {
        if isBlack(node.parent) {
            // Don't do anything if node is root or
            // node's parent's color is black
            if node.parent == nil {
                root = node
                node.color = .BLACK
            }
            return
        }
        let uncleNode = uncleNodeOf(node)
        // At this step, node's parent cannot be null (node is root)
        // and node's grandParent cannot be null (node's parent is not root)
        let grandParent = node.parent!.parent!
        if isBlack(uncleNode) {
            switch BalanceRotateOperationCase.of(node) {
            case .LeftLeft:
                rotateRight(node.parent!)
                exchangeNodeColor(grandParent, node.parent!)
            case .LeftRight:
                rotateLeft(node)
                rotateRight(node)
                exchangeNodeColor(grandParent, node)
            case .RightLeft:
                rotateRight(node)
                rotateLeft(node)
                exchangeNodeColor(grandParent, node)
            case .RightRight:
                rotateLeft(node.parent!)
                exchangeNodeColor(grandParent, node.parent!)
            default:
                return
            }
        } else {
            // uncle node's color is RED, first we set node's parent and uncle node
            // to BLACK
            node.parent?.color = .BLACK
            uncleNode?.color = .BLACK
            guard let grandParent = node.parent?.parent else {
                // node's parent is root, then stop here.
                return
            }
            // set grand parent color to RED
            grandParent.color = .RED
            // Continue fixing the tree starts at grand parent node.
            fixTreeAfterInsertIfNeeded(at: grandParent)
        }
    }
}

extension RBTree {

    fileprivate func isBlack(_ node: RBTreeNode<T>?) -> Bool {
        return node == nil || node!.color == .BLACK
    }

    fileprivate func exchangeNodeColor(_ node1: RBTreeNode<T>, _ node2: RBTreeNode<T>) {
        let tempColor = node1.color
        node1.color = node2.color
        node2.color = tempColor
    }

    fileprivate func uncleNodeOf(_ node: RBTreeNode<T>) -> RBTreeNode<T>? {
        guard let grandParent = node.parent?.parent else {
            return nil;
        }
        if grandParent.leftChild == node.parent {
            return grandParent.rightChild
        } else {
            return grandParent.leftChild
        }
    }
}
