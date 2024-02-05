CREATE TABLE [dbo].[Template] (
    [Id]         SMALLINT        IDENTITY (1, 1) NOT NULL,
    [LanguageId] TINYINT         NOT NULL,
    [TypeId]     TINYINT         NOT NULL,
    [Template]   NVARCHAR (4000) NOT NULL,
    CONSTRAINT [PK_Template] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Template_Language] FOREIGN KEY ([LanguageId]) REFERENCES [Enum].[Language] ([Id]),
    CONSTRAINT [FK_Template_TemplateType] FOREIGN KEY ([TypeId]) REFERENCES [Enum].[TemplateType] ([Id])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Template_LanguageId_TypeId]
    ON [dbo].[Template]([LanguageId] ASC, [TypeId] ASC);

