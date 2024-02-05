CREATE TABLE [Enum].[Language] (
    [Id]   TINYINT       NOT NULL,
    [Name] VARCHAR (200) NOT NULL,
    CONSTRAINT [PK_Enum_Language] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Enum_Language_Name]
    ON [Enum].[Language]([Name] ASC);

