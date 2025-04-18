#ifndef AST_H
#define AST_H

/* 节点类型枚举，根据你的文法再补充 */
typedef enum {
    NODE_PROGRAM,
    NODE_EXTDEFLIST,
    NODE_EXTDEF,
    NODE_SPECIFIER,
    NODE_STRUCTSPEC,   // 新增
    NODE_OPTAG,        // 新增
    NODE_TAG,          // 新增
    NODE_EXTDECLIST,   // 新增
    NODE_VARDEC,       // 新增
    NODE_FUNDEC,
    NODE_VARLIST,      // 新增
    NODE_PARAMDEC,     // 新增
    NODE_COMPST,
    NODE_DEFLIST,      // 新增
    NODE_DEF,          // 新增
    NODE_DECLIST,      // 新增
    NODE_DEC,          // 新增
    NODE_STMTLIST,     // 新增
    NODE_STMT,         // 新增
    NODE_EXP,          // 新增
    NODE_ARGS,         // 新增
    NODE_ID,     /* 叶子：标识符 */
    NODE_INT,    /* 叶子：整型常量 */
    NODE_FLOAT,  /* 叶子：浮点常量 */
} NodeType;

/* AST 节点 */
typedef struct ASTNode {
    NodeType        type;         /* 节点类型 */
    char           *text;         /* 对于 ID/常量，用来保存词素 */
    int             lineno;       /* 源码行号 */
    struct ASTNode *first_child;  /* 第一个子节点 */
    struct ASTNode *next_sibling; /* 下一个兄弟节点 */
} ASTNode;

/* 创建一个新节点 */
ASTNode *ast_new_node(NodeType type, const char *text, int lineno);

/* 将 child 加到 parent 的子列表尾部 */
void    ast_add_child(ASTNode *parent, ASTNode *child);

/* 递归打印 AST */
void    ast_print(ASTNode *node, int depth);

#endif /* AST_H */
