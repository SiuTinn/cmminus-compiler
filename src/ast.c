#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "ast.h"

ASTNode *ast_new_node(NodeType type, const char *text, int lineno) {
    ASTNode *n = malloc(sizeof(ASTNode));
    n->type         = type;
    n->lineno       = lineno;
    n->first_child  = NULL;
    n->next_sibling = NULL;
    if (text) {
        n->text = strdup(text);
    } else {
        n->text = NULL;
    }
    return n;
}

void ast_add_child(ASTNode *parent, ASTNode *child) {
    if (!parent || !child) return;
    if (!parent->first_child) {
        parent->first_child = child;
    } else {
        ASTNode *c = parent->first_child;
        while (c->next_sibling) c = c->next_sibling;
        c->next_sibling = child;
    }
}

/* 根据 type 打印可读的名字 */
static const char *node_type_name(NodeType t) {
    switch(t) {
        case NODE_PROGRAM:    return "Program";
        case NODE_EXTDEFLIST: return "ExtDefList";
        case NODE_EXTDEF:     return "ExtDef";
        case NODE_SPECIFIER:  return "Specifier";
        case NODE_FUNDEC:     return "FunDec";
        case NODE_COMPST:     return "CompSt";
        case NODE_ID:         return "ID";
        case NODE_INT:        return "INT";
        case NODE_FLOAT:      return "FLOAT";
        
        default:              return "Unknown";
    }
}

void ast_print(ASTNode *node, int depth) {
    if (!node) return;
    for (int i = 0; i < depth; i++) printf("  ");
    /* 打印节点基本信息 */
    printf("%s", node_type_name(node->type));
    if (node->text)        printf(": %s", node->text);
    printf(" (%d)\n", node->lineno);
    /* 递归子节点 */
    for (ASTNode *c = node->first_child; c; c = c->next_sibling) {
        ast_print(c, depth + 1);
    }
}
